import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';

/**
 * Legal content types
 */
export enum LegalContentType {
  TERMS = 'terms',
  PRIVACY = 'privacy',
}

/**
 * Entity for storing Terms & Conditions and Privacy Policy content.
 * Supports versioning and language-specific content.
 */
@Entity('legal_content')
@Index('ix_legal_content_type_language', ['type', 'language'])
export class LegalContentEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({
    type: 'enum',
    enum: LegalContentType,
  })
  type: LegalContentType;

  @Column({ type: 'varchar', length: 10, default: 'en' })
  language: string; // 'en' or 'ar'

  @Column({ type: 'text' })
  content: string; // HTML or markdown content

  @Column({ type: 'varchar', length: 50, nullable: true })
  version: string | null; // e.g., '1.0', '2.0'

  @Column({ default: true })
  isActive: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
