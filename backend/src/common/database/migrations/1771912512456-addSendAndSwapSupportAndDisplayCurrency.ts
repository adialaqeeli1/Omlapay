import { MigrationInterface, QueryRunner } from "typeorm";

export class AddSendAndSwapSupportAndDisplayCurrency1771912512456 implements MigrationInterface {
    name = 'AddSendAndSwapSupportAndDisplayCurrency1771912512456'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE "send_pending_requests" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "userId" uuid NOT NULL, "otpRequestId" uuid NOT NULL, "recipientType" character varying(20) NOT NULL, "recipientIdentifier" character varying(128) NOT NULL, "coinId" uuid NOT NULL, "network" character varying(50) NOT NULL, "amount" numeric(36,18) NOT NULL, "fee" numeric(36,18) NOT NULL DEFAULT '0', "recipientUserId" uuid, "recipientWalletId" uuid, "recipientAddress" character varying(128), "addressTag" character varying(64), "expiresAt" TIMESTAMP NOT NULL, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_f3d87385d774f3075ac183f9097" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE INDEX "ix_send_pending_expires_at" ON "send_pending_requests" ("expiresAt") `);
        await queryRunner.query(`CREATE INDEX "ix_send_pending_user_id" ON "send_pending_requests" ("userId") `);
        await queryRunner.query(`CREATE TYPE "public"."user_settings_displaycurrency_enum" AS ENUM('usd', 'sar')`);
        await queryRunner.query(`ALTER TABLE "user_settings" ADD "displayCurrency" "public"."user_settings_displaycurrency_enum" DEFAULT 'usd'`);
        await queryRunner.query(`ALTER TYPE "public"."otp_requests_purpose_enum" RENAME TO "otp_requests_purpose_enum_old"`);
        await queryRunner.query(`CREATE TYPE "public"."otp_requests_purpose_enum" AS ENUM('REGISTER', 'RESET', 'EMAIL_VERIFICATION', 'FORGOT_PASSCODE_MOBILE', 'FORGOT_PASSCODE_EMAIL', 'TWO_FACTOR_MOBILE', 'TWO_FACTOR_EMAIL', 'SEND_VERIFICATION')`);
        await queryRunner.query(`ALTER TABLE "otp_requests" ALTER COLUMN "purpose" TYPE "public"."otp_requests_purpose_enum" USING "purpose"::"text"::"public"."otp_requests_purpose_enum"`);
        await queryRunner.query(`DROP TYPE "public"."otp_requests_purpose_enum_old"`);
        await queryRunner.query(`ALTER TABLE "send_pending_requests" ADD CONSTRAINT "FK_15ca55630f420ad7ee0af1e517a" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "send_pending_requests" ADD CONSTRAINT "FK_dc02883713a6d7f41c264b25c8e" FOREIGN KEY ("coinId") REFERENCES "coins"("id") ON DELETE RESTRICT ON UPDATE NO ACTION`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "send_pending_requests" DROP CONSTRAINT "FK_dc02883713a6d7f41c264b25c8e"`);
        await queryRunner.query(`ALTER TABLE "send_pending_requests" DROP CONSTRAINT "FK_15ca55630f420ad7ee0af1e517a"`);
        await queryRunner.query(`CREATE TYPE "public"."otp_requests_purpose_enum_old" AS ENUM('REGISTER', 'RESET', 'EMAIL_VERIFICATION', 'FORGOT_PASSCODE_MOBILE', 'FORGOT_PASSCODE_EMAIL', 'TWO_FACTOR_MOBILE', 'TWO_FACTOR_EMAIL')`);
        await queryRunner.query(`ALTER TABLE "otp_requests" ALTER COLUMN "purpose" TYPE "public"."otp_requests_purpose_enum_old" USING "purpose"::"text"::"public"."otp_requests_purpose_enum_old"`);
        await queryRunner.query(`DROP TYPE "public"."otp_requests_purpose_enum"`);
        await queryRunner.query(`ALTER TYPE "public"."otp_requests_purpose_enum_old" RENAME TO "otp_requests_purpose_enum"`);
        await queryRunner.query(`ALTER TABLE "user_settings" DROP COLUMN "displayCurrency"`);
        await queryRunner.query(`DROP TYPE "public"."user_settings_displaycurrency_enum"`);
        await queryRunner.query(`DROP INDEX "public"."ix_send_pending_user_id"`);
        await queryRunner.query(`DROP INDEX "public"."ix_send_pending_expires_at"`);
        await queryRunner.query(`DROP TABLE "send_pending_requests"`);
    }

}
