import { MigrationInterface, QueryRunner } from 'typeorm';

// OTP purpose for logging in an existing user with an SMS code (POST /v1/auth/login/send-otp).
export class AddLoginOtpPurpose1793915714425 implements MigrationInterface {
  name = 'AddLoginOtpPurpose1793915714425';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TYPE "public"."otp_requests_purpose_enum" ADD VALUE IF NOT EXISTS 'LOGIN'`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `DELETE FROM "otp_requests" WHERE "purpose" = 'LOGIN'`,
    );
    await queryRunner.query(
      `ALTER TYPE "public"."otp_requests_purpose_enum" RENAME TO "otp_requests_purpose_enum_old"`,
    );
    await queryRunner.query(
      `CREATE TYPE "public"."otp_requests_purpose_enum" AS ENUM('REGISTER', 'RESET', 'EMAIL_VERIFICATION', 'FORGOT_PASSCODE_MOBILE', 'FORGOT_PASSCODE_EMAIL', 'TWO_FACTOR_MOBILE', 'TWO_FACTOR_EMAIL', 'SEND_VERIFICATION')`,
    );
    await queryRunner.query(
      `ALTER TABLE "otp_requests" ALTER COLUMN "purpose" TYPE "public"."otp_requests_purpose_enum" USING "purpose"::"text"::"public"."otp_requests_purpose_enum"`,
    );
    await queryRunner.query(
      `DROP TYPE "public"."otp_requests_purpose_enum_old"`,
    );
  }
}
