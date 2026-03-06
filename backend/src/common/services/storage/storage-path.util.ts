/** Root folder for non-production uploads (dev, staging) */
export const STAGING_ROOT = 'staging';

/** Root folder for production uploads with segregated subfolders (support-requests, profile, etc.) */
export const UPLOADS_ROOT = 'uploads';

const NON_PRODUCTION_ENVS = ['staging', 'development', 'dev'];

/**
 * Returns the storage root path based on NODE_ENV.
 * - dev | development | staging: uploads go to staging/uploads/
 * - production (or other): uploads go to uploads/
 */
export function getStorageRoot(nodeEnv?: string): string {
  const env = (nodeEnv || process.env.NODE_ENV || '').toLowerCase();
  return NON_PRODUCTION_ENVS.includes(env)
    ? `${STAGING_ROOT}/${UPLOADS_ROOT}`
    : UPLOADS_ROOT;
}
