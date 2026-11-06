import { MigrationInterface, QueryRunner } from 'typeorm';

// Remembered devices for POST /v1/auth/login/passcode (login without a new SMS code).
export class AddTrustedDevices1793963763623 implements MigrationInterface {
  name = 'AddTrustedDevices1793963763623';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TABLE "trusted_devices" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "userId" uuid NOT NULL, "tokenHash" character varying(64) NOT NULL, "deviceId" character varying(128), "expiresAt" TIMESTAMP NOT NULL, "lastUsedAt" TIMESTAMP, "revokedAt" TIMESTAMP, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_trusted_devices_id" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE INDEX "ix_trusted_devices_user_id" ON "trusted_devices" ("userId")`,
    );
    await queryRunner.query(
      `CREATE UNIQUE INDEX "ux_trusted_devices_token_hash" ON "trusted_devices" ("tokenHash")`,
    );
    await queryRunner.query(
      `ALTER TABLE "trusted_devices" ADD CONSTRAINT "FK_trusted_devices_user" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "auth_sessions" ADD "trustedDeviceId" uuid`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "auth_sessions" DROP COLUMN "trustedDeviceId"`,
    );
    await queryRunner.query(`DROP TABLE "trusted_devices"`);
  }
}
