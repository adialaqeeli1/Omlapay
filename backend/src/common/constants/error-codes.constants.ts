/**
 * Error codes for user-facing API responses.
 * Used by Send, Swap, Receive services.
 */
export const ErrorCodes = {
  KYC_REQUIRED: 'KYC_REQUIRED',
  API_KEYS_MISSING: 'API_KEYS_MISSING',
  RECIPIENT_KYC_REQUIRED: 'RECIPIENT_KYC_REQUIRED',
} as const;
