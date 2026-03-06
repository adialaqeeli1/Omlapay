/** Omlapay system fee (platform fee) - default 0.1%, now configurable via admin */
export const OMLAPAY_SWAP_FEE_PERCENT = 0.001;

/** Binance trading fee (0.1%) */
export const BINANCE_FEE_PERCENT = 0.001;

/** Idempotency key time window (5 minutes) - same params within window share key for retries */
export const IDEMPOTENCY_WINDOW_MS = 5 * 60 * 1000;
