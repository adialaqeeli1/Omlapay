enum KycVerificationEntrySource {
  profile,
  send,
  receive,
  swap,
  receiveHistory,
  unknown;

  static KycVerificationEntrySource fromExtra(Object? extra) {
    if (extra is KycVerificationEntrySource) {
      return extra;
    }

    if (extra is String) {
      final normalized = extra.trim();
      if (normalized == 'receive_history') {
        return KycVerificationEntrySource.receiveHistory;
      }
      return KycVerificationEntrySource.values.firstWhere(
        (value) => value.name == normalized,
        orElse: () => KycVerificationEntrySource.unknown,
      );
    }

    return KycVerificationEntrySource.unknown;
  }
}
