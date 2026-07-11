import '../../../routes/app_router.dart';

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

  String get sourceRoute {
    switch (this) {
      case KycVerificationEntrySource.profile:
        return Routes.profile;
      default:
        return Routes.home;
    }
  }
}
