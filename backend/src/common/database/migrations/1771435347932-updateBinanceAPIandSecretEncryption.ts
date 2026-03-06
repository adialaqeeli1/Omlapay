import { MigrationInterface, QueryRunner } from "typeorm";

export class UpdateBinanceAPIandSecretEncryption1771435347932 implements MigrationInterface {
    name = 'UpdateBinanceAPIandSecretEncryption1771435347932'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "binance_api_key"`);
        await queryRunner.query(`ALTER TABLE "users" ADD "binance_api_key" character varying(512)`);
        await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "binance_secret_key"`);
        await queryRunner.query(`ALTER TABLE "users" ADD "binance_secret_key" character varying(512)`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "binance_secret_key"`);
        await queryRunner.query(`ALTER TABLE "users" ADD "binance_secret_key" character varying(255)`);
        await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "binance_api_key"`);
        await queryRunner.query(`ALTER TABLE "users" ADD "binance_api_key" character varying(255)`);
    }

}
