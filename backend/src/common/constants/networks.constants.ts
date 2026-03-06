/**
 * Supported networks across Send, Receive.
 * Maps network identifier to display name and supported coins.
 */
export const SUPPORTED_NETWORKS = [
  {
    network: 'TRX',
    displayName: 'Tron (TRC20)',
    coins: ['USDT', 'USDC'] as const,
  },
  {
    network: 'BTC',
    displayName: 'Bitcoin',
    coins: ['BTC'] as const,
  },
  {
    network: 'ETH',
    displayName: 'EVM (Ethereum)',
    coins: ['ETH'] as const,
  },
  {
    network: 'BNB',
    displayName: 'EVM (BNB Chain)',
    coins: ['BNB'] as const,
  },
  {
    network: 'SOL',
    displayName: 'Solana',
    coins: ['SOL'] as const,
  },
] as const;

export type SupportedNetwork = (typeof SUPPORTED_NETWORKS)[number]['network'];

/** Coin → network mapping for Send (matches Receive) */
export const COIN_TO_NETWORK_MAP: Record<string, string> = {
  USDT: 'TRX',
  USDC: 'TRX',
  BTC: 'BTC',
  ETH: 'ETH',
  BNB: 'BNB',
  SOL: 'SOL',
};
