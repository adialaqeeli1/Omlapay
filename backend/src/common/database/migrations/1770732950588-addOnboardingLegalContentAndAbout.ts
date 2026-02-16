import { MigrationInterface, QueryRunner } from "typeorm";

export class AddOnboardingLegalContentAndAbout1770732950588 implements MigrationInterface {
    name = 'AddOnboardingLegalContentAndAbout1770732950588'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TYPE "public"."legal_content_type_enum" AS ENUM('terms', 'privacy')`);
        await queryRunner.query(`CREATE TABLE "legal_content" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "type" "public"."legal_content_type_enum" NOT NULL, "language" character varying(10) NOT NULL DEFAULT 'en', "content" text NOT NULL, "version" character varying(50), "isActive" boolean NOT NULL DEFAULT true, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_8ecceadc3ef1a9c989260933d23" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE INDEX "ix_legal_content_type_language" ON "legal_content" ("type", "language") `);
        await queryRunner.query(`CREATE TABLE "about" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "language" character varying(10) NOT NULL DEFAULT 'en', "description" text NOT NULL, "features" json, "mission" text, "vision" text, "isActive" boolean NOT NULL DEFAULT true, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_e7b581a8a74d0a2ea3aa53226ee" PRIMARY KEY ("id"))`);
        await queryRunner.query(`ALTER TABLE "user_settings" ADD "onboardingCompleted" boolean NOT NULL DEFAULT false`);
        await queryRunner.query(`ALTER TABLE "user_settings" ADD "onboardingSkipped" boolean NOT NULL DEFAULT false`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "user_settings" DROP COLUMN "onboardingSkipped"`);
        await queryRunner.query(`ALTER TABLE "user_settings" DROP COLUMN "onboardingCompleted"`);
        await queryRunner.query(`DROP TABLE "about"`);
        await queryRunner.query(`DROP INDEX "public"."ix_legal_content_type_language"`);
        await queryRunner.query(`DROP TABLE "legal_content"`);
        await queryRunner.query(`DROP TYPE "public"."legal_content_type_enum"`);
    }

}
