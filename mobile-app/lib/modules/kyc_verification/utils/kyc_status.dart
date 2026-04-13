/// Derived KYC verification status based on sumsub + binance statuses.
enum KycStatus {
  /// KYC not started — user hasn't submitted anything yet.
  notStarted,

  /// SumSub approved, waiting for Binance — submitted and under review.
  pending,

  /// Both SumSub and Binance approved — fully verified.
  approved,

  /// SumSub approved but Binance rejected.
  rejected,
}
