/**
 * Binance trading pair mapping (quote = USDT).
 * Shared by Swap, Price, and ExchangeInfo services.
 */
export const COIN_TO_BINANCE_SYMBOL: Record<string, string> = {
  USDT: 'USDT',
  USDC: 'USDCUSDT',
  BTC: 'BTCUSDT',
  ETH: 'ETHUSDT',
  SOL: 'SOLUSDT',
  BNB: 'BNBUSDT',
};
