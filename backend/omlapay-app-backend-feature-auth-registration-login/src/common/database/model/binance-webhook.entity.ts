import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';

@Entity('binance_webhooks')
@Index('ix_binance_webhooks_created_at', ['createdAt'])
@Index('ix_binance_webhooks_processed', ['processed'])
@Index('ix_binance_webhooks_transaction_id', ['transactionId'])
export class BinanceWebhookEntity {
  @PrimaryGeneratedColumn('uuid', { name: 'webhook_id' })
  webhookId: string;

  @Column({ type: 'varchar', length: 100, name: 'event_type' })
  eventType: string;

  @Column({ type: 'jsonb' })
  payload: any;

  @Column({ type: 'boolean', default: false })
  processed: boolean;

  @Column({ type: 'uuid', nullable: true, name: 'transaction_id' })
  transactionId: string | null;

  @Column({ type: 'text', nullable: true, name: 'error_message' })
  errorMessage: string | null;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'processed_at' })
  processedAt: Date;
}

