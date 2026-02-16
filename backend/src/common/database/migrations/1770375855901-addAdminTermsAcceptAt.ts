import { MigrationInterface, QueryRunner } from "typeorm";

export class AddAdminTermsAcceptAt1770375855901 implements MigrationInterface {
    name = 'AddAdminTermsAcceptAt1770375855901'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "admins" ADD "terms_accepted_at" TIMESTAMP`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "admins" DROP COLUMN "terms_accepted_at"`);
    }

}
