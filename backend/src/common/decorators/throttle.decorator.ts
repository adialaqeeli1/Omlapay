import { Throttle } from '@nestjs/throttler';

/**
 * Per-client-IP rate limits for sensitive routes (the global default is set in AppModule).
 * Limits are per minute. Behind Caddy, set TRUST_PROXY_HOPS=1 so the real client IP is used.
 */
const MINUTE = 60_000;

/** Routes that send an SMS or email code: 3 per minute. */
export const ThrottleCodeSend = () =>
  Throttle({ default: { limit: 3, ttl: MINUTE } });

/** Routes that check a code, passcode or password: 5 per minute. */
export const ThrottleCredentialCheck = () =>
  Throttle({ default: { limit: 5, ttl: MINUTE } });

/** Account lookups (e.g. does this number have an account): 10 per minute. */
export const ThrottleLookup = () =>
  Throttle({ default: { limit: 10, ttl: MINUTE } });
