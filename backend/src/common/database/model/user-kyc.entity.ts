import {
    Entity,
    PrimaryGeneratedColumn,
    Column,
    ManyToOne,
    CreateDateColumn,
    UpdateDateColumn,
    Index,
  } from 'typeorm';
  import { UserEntity } from './user.entity';
  
  /**
   * KYC verification statuses matching Sumsub applicant flow.
   * @see https://docs.sumsub.com/docs/applicant-statuses`
   */
  export enum KycStatus {
    /** Documents requested - applicant created, needs to submit required data */
    INIT = 'INIT',
    /** Pending - applicant provided data, moved to verification processing */
    PENDING = 'PENDING',
    /** Awaiting service - paused due to long-running external process (async DB, service operation) */
    AWAITING_SERVICE = 'AWAITING_SERVICE',
    /** Requires action - manual check started or expects final decision */
    ON_HOLD = 'ON_HOLD',
    /** Awaiting user - requires user action other than document submission (e.g., business verification) */
    AWAITING_USER = 'AWAITING_USER',
    /** Approved - successfully passed all verification checks */
    APPROVED = 'APPROVED',
    /** Rejected - failed checks, not allowed to retry (reviewRejectType: FINAL) */
    REJECTED = 'REJECTED',
    /** Resubmission requested - failed checks but can retry (reviewRejectType: RETRY) */
    RESUBMISSION_REQUESTED = 'RESUBMISSION_REQUESTED',
  }

  /**
   * Rejection type for failed KYC verifications.
   */
  export enum KycRejectType {
    /** User can resubmit and try again */
    RETRY = 'RETRY',
    /** Final rejection, user cannot retry */
    FINAL = 'FINAL',
  }
  
  export enum KycLevel {
    BASIC = 'BASIC',
    INTERMEDIATE = 'INTERMEDIATE',
    ADVANCED = 'ADVANCED',
  }

  /**
   * KYC providers in the system.
   * Flow: SUMSUB (identity verification) must be APPROVED before BINANCE (exchange verification) can be initiated.
   */
  export enum KycProvider {
    SUMSUB = 'SUMSUB',
    BINANCE = 'BINANCE',
  }

  /**
   * Provider dependencies: which KYC must be completed before this one.
   */
  export const KYC_PREREQUISITES: Record<KycProvider, KycProvider | null> = {
    [KycProvider.SUMSUB]: null, // No prerequisite, first step
    [KycProvider.BINANCE]: KycProvider.SUMSUB, // Requires Sumsub approval
  };
  
  @Entity('user_kyc')
  @Index('ix_user_kyc_user_id', ['userId'])
  @Index('ix_user_kyc_status', ['status'])
  @Index('ux_user_kyc_user_provider', ['userId', 'provider'], { unique: true })
  export class UserKycEntity {
    @PrimaryGeneratedColumn('uuid')
    id: string;
  
    @Column('uuid')
    userId: string;
  
    @ManyToOne(() => UserEntity, { onDelete: 'CASCADE' })
    user: UserEntity;
  
    @Column({
      type: 'enum',
      enum: KycStatus,
      default: KycStatus.INIT,
    })
    status: KycStatus;
  
    @Column({
      type: 'enum',
      enum: KycLevel,
      default: KycLevel.BASIC,
    })
    level: KycLevel;
  
    @Column({ type: 'varchar', length: 50 })
    provider: string;
  
    @Column({ type: 'varchar', length: 100, nullable: true })
    referenceId: string | null;

    /** Sumsub reviewAnswer (GREEN/RED) or equivalent from other providers */
    @Column({ type: 'varchar', length: 20, nullable: true })
    reviewAnswer: string | null;

    /** Type of rejection: RETRY (can resubmit) or FINAL (cannot retry) */
    @Column({ type: 'varchar', length: 20, nullable: true })
    rejectType: KycRejectType | null;
  
    @Column({ type: 'text', nullable: true })
    rejectionReason: string | null;
  
    @Column({ type: 'timestamp', nullable: true })
    verifiedAt: Date | null;

    /** Raw JSON from provider (e.g. Sumsub applicant response or webhook payload) for debugging/audit */
    @Column({ type: 'jsonb', nullable: true })
    providerPayload: Record<string, unknown> | null;

    @CreateDateColumn()
    createdAt: Date;
  
    @UpdateDateColumn()
    updatedAt: Date;

    /**
     * Check if a user has completed the prerequisite KYC for a given provider.
     * Returns true if prerequisite is met or not required.
     */
    static async canStartKyc(
      userId: string,
      provider: KycProvider,
      repository: any, // Repository<UserKycEntity>
    ): Promise<{ allowed: boolean; reason?: string }> {
      const prerequisite = KYC_PREREQUISITES[provider];
      
      if (!prerequisite) {
        return { allowed: true }; // No prerequisite required
      }

      const prerequisiteKyc = await repository.findOne({
        where: { userId, provider: prerequisite },
      });

      if (!prerequisiteKyc) {
        return {
          allowed: false,
          reason: `${prerequisite} KYC must be initiated first`,
        };
      }

      if (prerequisiteKyc.status !== KycStatus.APPROVED) {
        return {
          allowed: false,
          reason: `${prerequisite} KYC must be approved before starting ${provider} KYC (current status: ${prerequisiteKyc.status})`,
        };
      }

      return { allowed: true };
    }

    /**
     * Map Sumsub webhook reviewStatus to our KycStatus enum.
     * @param reviewStatus - Sumsub reviewStatus (init, pending, completed, etc.)
     * @param reviewAnswer - Sumsub reviewAnswer (GREEN/RED)
     * @param reviewRejectType - Sumsub reviewRejectType (RETRY/FINAL)
     */
    static mapSumsubStatus(
      reviewStatus: string,
      reviewAnswer?: string,
      reviewRejectType?: string,
    ): KycStatus {
      switch (reviewStatus) {
        case 'init':
          return KycStatus.INIT;
        case 'pending':
          return KycStatus.PENDING;
        case 'awaitingService':
          return KycStatus.AWAITING_SERVICE;
        case 'onHold':
          return KycStatus.ON_HOLD;
        case 'awaitingUser':
          return KycStatus.AWAITING_USER;
        case 'completed':
          if (reviewAnswer === 'GREEN') {
            return KycStatus.APPROVED;
          } else if (reviewAnswer === 'RED') {
            return reviewRejectType === 'RETRY'
              ? KycStatus.RESUBMISSION_REQUESTED
              : KycStatus.REJECTED;
          }
          return KycStatus.PENDING; // Fallback
        default:
          return KycStatus.PENDING;
      }
    }

    /**
     * Map Binance KYC status to our KycStatus enum.
     * Binance statuses: INITIAL, PROCESS, REVIEW, PASS, REJECT, REFUSED, DISABLE
     * @param binanceStatus - Binance KYC status from their API/webhook
     */
    static mapBinanceStatus(binanceStatus: string): KycStatus {
      switch (binanceStatus?.toUpperCase()) {
        case 'INITIAL':
          return KycStatus.INIT;
        case 'PROCESS':
          return KycStatus.PENDING;
        case 'REVIEW':
          return KycStatus.ON_HOLD;
        case 'PASS':
          return KycStatus.APPROVED;
        case 'REJECT':
        case 'REFUSED':
          return KycStatus.REJECTED;
        case 'DISABLE':
          return KycStatus.REJECTED;
        default:
          return KycStatus.PENDING;
      }
    }
  }