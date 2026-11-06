import { MigrationInterface, QueryRunner } from 'typeorm';

// Push-notification devices (POST /v1/notifications/devices). New table only.
export class AddPushDevices1793995356199 implements MigrationInterface {
  name = 'AddPushDevices1793995356199';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TABLE "push_devices" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "userId" uuid NOT NULL, "deviceToken" character varying(4096) NOT NULL, "deviceUuid" character varying(255) NOT NULL, "deviceModel" character varying(100) NOT NULL, "sessionId" uuid, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_push_devices_id" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE INDEX "ix_push_devices_user_id" ON "push_devices" ("userId")`,
    );
    await queryRunner.query(
      `CREATE UNIQUE INDEX "ux_push_devices_device_token" ON "push_devices" ("deviceToken")`,
    );
    await queryRunner.query(
      `ALTER TABLE "push_devices" ADD CONSTRAINT "FK_push_devices_user" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE "push_devices"`);
  }
}
