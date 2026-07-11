/// Returns the mainnet block-explorer transaction URL for a given [network]
/// and [txHash], or `null` when either input is empty or the network isn't in
/// the canonical list below.
///
/// The [network] match is case-insensitive and accepts the common aliases a
/// chain shows up as in the history API (e.g. `ETH` / `ERC20`, `TRX` / `TRON`
/// / `TRC20`). Callers should treat `null` as "no explorer available" and fall
/// back to a plain, non-tappable display.
String? blockExplorerTxUrl({String? network, String? txHash}) {
  final hash = txHash?.trim() ?? '';
  final net = network?.trim().toUpperCase() ?? '';
  if (hash.isEmpty || net.isEmpty) return null;

  switch (net) {
    case 'BTC':
    case 'BITCOIN':
      return 'https://mempool.space/tx/$hash';
    case 'ETH':
    case 'ETHEREUM':
    case 'ERC20':
      return 'https://etherscan.io/tx/$hash';
    case 'SOL':
    case 'SOLANA':
      return 'https://solscan.io/tx/$hash';
    case 'TRX':
    case 'TRON':
    case 'TRC20':
      return 'https://tronscan.org/#/transaction/$hash';
    case 'BSC':
    case 'BNB':
    case 'BEP20':
      return 'https://bscscan.com/tx/$hash';
    default:
      return null;
  }
}
