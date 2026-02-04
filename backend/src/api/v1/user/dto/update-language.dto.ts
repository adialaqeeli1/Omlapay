import { IsEnum, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { Language } from '@common/database/model';

export class UpdateLanguageDto {
  @ApiProperty({ enum: Language, example: 'ar' })
  @IsEnum(Language)
  @IsNotEmpty()
  language: Language;
}
