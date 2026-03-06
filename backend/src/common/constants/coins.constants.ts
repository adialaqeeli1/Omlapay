/**
 * Supported coins across Send, Swap, Receive, History.
 * Single source of truth for asset lists.
 */
export const SUPPORTED_COINS = [
  'USDT',
  'USDC',
  'BTC',
  'ETH',
  'BNB',
  'SOL',
] as const;

export type SupportedCoin = (typeof SUPPORTED_COINS)[number];

/** Asset filter including ALL for history/receive/send */
export type AssetFilter = 'ALL' | SupportedCoin;

export const ASSET_FILTERS: AssetFilter[] = [
  'ALL',
  'USDT',
  'USDC',
  'BTC',
  'ETH',
  'BNB',
  'SOL',
];

/** Stablecoins (price ≈ 1 USD) */
export const STABLECOINS = ['USDT', 'USDC'] as const;

export function isStablecoin(symbol: string): boolean {
  return STABLECOINS.includes(
    symbol.toUpperCase() as (typeof STABLECOINS)[number],
  );
}
