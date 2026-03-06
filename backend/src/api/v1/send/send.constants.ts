/** Max transfer per transaction in USD */
export const MAX_TRANSFER_USD = 100_000;

/** Min transfer per transaction in USD equivalent */
export const MIN_TRANSFER_USD = 10;

/** External wallet address length validation (EIP-55, etc.) */
export const MIN_ADDRESS_LENGTH = 20;
export const MAX_ADDRESS_LENGTH = 128;

/** Estimated completion time for external withdrawals (5 minutes) */
export const SEND_ESTIMATED_COMPLETION_MS = 5 * 60 * 1000;
