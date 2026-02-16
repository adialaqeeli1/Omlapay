import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

/**
 * Entity for storing About Omlapay content.
 * Supports language-specific content and features list.
 */
@Entity('about')
export class AboutEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', length: 10, default: 'en' })
  language: string; // 'en' or 'ar'

  @Column({ type: 'text' })
  description: string; // Brief description of Omlapay

  @Column({ type: 'json', nullable: true })
  features: string[] | null; // Array of feature descriptions

  @Column({ type: 'text', nullable: true })
  mission: string | null; // Mission statement

  @Column({ type: 'text', nullable: true })
  vision: string | null; // Vision statement

  @Column({ default: true })
  isActive: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
