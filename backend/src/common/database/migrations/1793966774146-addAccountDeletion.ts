import { MigrationInterface, QueryRunner } from 'typeorm';

// Account deletion: 7-day grace period, then personal data is anonymized.
export class AddAccountDeletion1793966774146 implements MigrationInterface {
  name = 'AddAccountDeletion1793966774146';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "users" ADD "deletionRequestedAt" TIMESTAMP, ADD "deletionScheduledFor" TIMESTAMP, ADD "anonymizedAt" TIMESTAMP`,
    );
    await queryRunner.query(
      `CREATE INDEX "ix_users_deletion_scheduled_for" ON "users" ("deletionScheduledFor") WHERE "anonymizedAt" IS NULL AND "deletionScheduledFor" IS NOT NULL`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `DROP INDEX "public"."ix_users_deletion_scheduled_for"`,
    );
    await queryRunner.query(
      `ALTER TABLE "users" DROP COLUMN "anonymizedAt", DROP COLUMN "deletionScheduledFor", DROP COLUMN "deletionRequestedAt"`,
    );
  }
}
