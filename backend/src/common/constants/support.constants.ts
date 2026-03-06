/**
 * Support email for user block notifications and internal stakeholder alerts.
 * Set SUPPORT_EMAIL in production; falls back to placeholder in development only.
 */
export function getSupportEmail(): string {
  const email = process.env.SUPPORT_EMAIL;
  if (process.env.NODE_ENV === 'production' && (!email || !email.trim())) {
    throw new Error('SUPPORT_EMAIL must be set in production.');
  }
  return email?.trim() || 'support@omlapay.com';
}

/** App download/invite URL for SMS invitations. Override via APP_INVITE_URL env. */
export const APP_INVITE_URL =
  process.env.APP_INVITE_URL ?? 'https://omlapay.com/download';
