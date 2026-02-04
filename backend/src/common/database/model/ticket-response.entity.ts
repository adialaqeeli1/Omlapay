import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  Index,
} from 'typeorm';
import { SupportRequestEntity } from './support-request.entity';
import { AdminEntity } from './admin.entity';

@Entity('ticket_responses')
@Index('ix_ticket_responses_ticket_id', ['ticketId'])
@Index('ix_ticket_responses_created_at', ['createdAt'])
export class TicketResponseEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid', name: 'ticket_id' })
  ticketId: string;

  @ManyToOne(() => SupportRequestEntity, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'ticket_id' })
  ticket: SupportRequestEntity;

  @Column({ type: 'uuid', nullable: true, name: 'admin_id' })
  adminId: string | null;

  @ManyToOne(() => AdminEntity, { onDelete: 'SET NULL', nullable: true })
  @JoinColumn({ name: 'admin_id' })
  admin: AdminEntity | null;

  @Column({ type: 'text' })
  message: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
