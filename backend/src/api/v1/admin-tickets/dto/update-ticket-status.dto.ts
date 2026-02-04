import { IsEnum, IsOptional, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { SupportRequestStatus } from '@common/database/model';

export class UpdateTicketStatusDto {
  @ApiProperty({
    description: 'New ticket status',
    enum: SupportRequestStatus,
    example: SupportRequestStatus.SOLVED,
  })
  @IsEnum(SupportRequestStatus)
  status: SupportRequestStatus;

  @ApiProperty({
    description: 'Optional comment when updating status',
    required: false,
    example: 'Issue resolved successfully',
  })
  @IsOptional()
  @IsString()
  comment?: string;
}
