import { IsEnum, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { Theme } from '@common/database/model';

export class UpdateAppearanceDto {
  @ApiProperty({ enum: Theme, example: 'dark' })
  @IsEnum(Theme)
  @IsNotEmpty()
  theme: Theme;
}
