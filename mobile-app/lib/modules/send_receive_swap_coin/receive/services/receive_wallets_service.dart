import '../../../../core/constants/endpoints.dart';
import '../../../../core/models/wallet_model/wallet_model.dart';
import '../../../../core/services/api_helper.dart';
import '../../../../core/utils/app_exception.dart';

class ReceiveWalletsResult {
  const ReceiveWalletsResult({
    required this.networks,
    required this.kycRequired,
  });

  final List<WalletNetworkModel> networks;
  final bool kycRequired;
}

class ReceiveWalletsService {
  Future<ReceiveWalletsResult> fetchWallets() async {
    final response = await ApiHelper.get(Endpoints.receiveWallets);
    final dynamic data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw AppException(
        'Invalid receive wallets response',
        messageKey: 'requestFailed',
      );
    }

    final dynamic walletsPayload = data['wallets'];
    if (walletsPayload is! List) {
      throw AppException('Invalid wallets list', messageKey: 'requestFailed');
    }

    final kycRequired = data['kycRequired'] == true;
    final networks = <WalletNetworkModel>[];
    for (final networkEntry in walletsPayload.whereType<Map<String, dynamic>>()) {
      final networkModel = WalletNetworkModel.fromJson(networkEntry);
      final networkCode = networkModel.network.trim().toUpperCase();
      final normalizedCoins = <WalletCoinModel>[];
      for (final coin in networkModel.coins) {
        final coinSymbol = coin.symbol.trim().toUpperCase();
        if (coinSymbol.isEmpty) {
          continue;
        }

        final coinName = coin.name.trim();
        final rawAddress = coin.address?.trim();
        final normalizedAddress = (rawAddress == null ||
                rawAddress.isEmpty ||
                rawAddress.toLowerCase() == 'null')
            ? ''
            : rawAddress;

        normalizedCoins.add(
          coin.copyWith(
            name: coinName.isEmpty ? coinSymbol : coinName,
            symbol: coinSymbol,
            address: normalizedAddress,
            network: networkCode.isEmpty ? 'N/A' : networkCode,
            networkDisplayName: networkModel.networkDisplayName.trim(),
            networkIconUrl: networkModel.networkIconUrl.trim(),
          ),
        );
      }

      networks.add(
        networkModel.copyWith(
          network: networkCode.isEmpty ? 'N/A' : networkCode,
          networkDisplayName: networkModel.networkDisplayName.trim(),
          networkIconUrl: networkModel.networkIconUrl.trim(),
          coins: normalizedCoins,
        ),
      );
    }

    return ReceiveWalletsResult(networks: networks, kycRequired: kycRequired);
  }
}
