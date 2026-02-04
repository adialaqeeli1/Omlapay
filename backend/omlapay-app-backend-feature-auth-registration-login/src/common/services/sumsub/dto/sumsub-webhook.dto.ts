import { IsString, IsOptional, IsObject } from 'class-validator';

/**
 * Sumsub webhook payload (POST to webhook URL).
 * Key fields: applicantId, externalUserId (our user id), type, reviewStatus, reviewResult.
 */
export class SumsubWebhookDto {
  @IsString()
  applicantId: string;

  @IsString()
  @IsOptional()
  inspectionId?: string;

  @IsString()
  @IsOptional()
  correlationId?: string;

  @IsString()
  @IsOptional()
  levelName?: string;

  @IsString()
  @IsOptional()
  externalUserId?: string;

  @IsString()
  type: string;

  @IsString()
  reviewStatus: string;

  @IsString()
  @IsOptional()
  createdAt?: string;

  @IsObject()
  @IsOptional()
  reviewResult?: {
    reviewAnswer?: string;
    rejectLabels?: string[];
    reviewRejectType?: string;
    moderationComment?: string;
    clientComment?: string;
  };

  @IsString()
  @IsOptional()
  applicantActionId?: string;

  @IsString()
  @IsOptional()
  applicantType?: string;

  @IsString()
  @IsOptional()
  sandboxMode?: string;
}

/** Applicant object returned by Sumsub API (GET applicant by id or externalUserId). */
export interface SumsubApplicantResponse {
  id: string;
  createdAt: string;
  key: string;
  clientId: string;
  inspectionId: string;
  externalUserId: string;
  info?: {
    firstName?: string;
    lastName?: string;
    dob?: string;
    country?: string;
    nationality?: string;
    addresses?: Array<{ country?: string; town?: string; street?: string; postCode?: string }>;
    idDocs?: Array<{
      idDocType?: string;
      number?: string;
      validUntil?: string;
      country?: string;
      firstName?: string;
      lastName?: string;
      dob?: string;
    }>;
  };
  email?: string;
  phone?: string;
  review?: {
    reviewId: string;
    attemptId: string;
    attemptCnt: number;
    levelName: string;
    createDate: string;
    reviewStatus: string;
    priority: number;
    reviewResult?: {
      reviewAnswer?: string;
      rejectLabels?: string[];
      reviewRejectType?: string;
    };
  };
}

/** Response from Sumsub SDK access token endpoint (used to init WebSDK). */
export interface SumsubAccessTokenResponse {
  token: string;
  userId: string;
}
