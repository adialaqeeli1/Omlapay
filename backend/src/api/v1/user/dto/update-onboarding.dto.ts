import { IsEnum, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export enum OnboardingAction {
  COMPLETE = 'complete',
  SKIP = 'skip',
}

/**
 * DTO for updating onboarding status.
 * Single endpoint handles both complete and skip actions.
 */
export class UpdateOnboardingDto {
  @ApiProperty({
    description: 'Onboarding action: complete or skip',
    enum: OnboardingAction,
    example: OnboardingAction.COMPLETE,
  })
  @IsEnum(OnboardingAction)
  @IsNotEmpty()
  action: OnboardingAction;
}
