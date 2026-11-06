import { MigrationInterface, QueryRunner } from 'typeorm';

// Support requests without an account (POST /v1/guest/support-requests):
// userId may be empty for guests, who are identified by a server-issued token (stored hashed).
export class AddGuestSupportRequests1793996375241 implements MigrationInterface {
  name = 'AddGuestSupportRequests1793996375241';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "support_requests" ALTER COLUMN "userId" DROP NOT NULL`,
    );
    await queryRunner.query(
      `ALTER TABLE "support_requests" ADD "guestTokenHash" character varying(64)`,
    );
    await queryRunner.query(
      `CREATE INDEX "ix_support_requests_guest_token_hash" ON "support_requests" ("guestTokenHash")`,
    );
    // Every request belongs either to an account or to a guest token
    await queryRunner.query(
      `ALTER TABLE "support_requests" ADD CONSTRAINT "ck_support_requests_owner" CHECK ("userId" IS NOT NULL OR "guestTokenHash" IS NOT NULL)`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "support_requests" DROP CONSTRAINT "ck_support_requests_owner"`,
    );
    await queryRunner.query(
      `DROP INDEX "public"."ix_support_requests_guest_token_hash"`,
    );
    await queryRunner.query(
      `DELETE FROM "support_requests" WHERE "userId" IS NULL`,
    );
    await queryRunner.query(
      `ALTER TABLE "support_requests" DROP COLUMN "guestTokenHash"`,
    );
    await queryRunner.query(
      `ALTER TABLE "support_requests" ALTER COLUMN "userId" SET NOT NULL`,
    );
  }
}
