import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/extentions/context_extensions.dart';

import '../../../../core/models/wallet_model/wallet_model.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../widgets/common_back_button.dart';
import '../../../../widgets/common_coin_icon.dart';
import '../../../dashboard/history/widgets/image_save_as_bottom_sheet.dart';
import '../provider/qr_code_provider.dart';

class QrCodeView extends StatelessWidget {
  const QrCodeView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<QrCodeProvider>();
    final selectedCoin = provider.selectedCoin;

    final currentAddress = selectedCoin?.address;

    final titleStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedCoin != null ? selectedCoin.symbol.substring(0, 1) : '',
              style: titleStyle,
            ),
            const SizedBox(width: 4),
            Text(selectedCoin?.name ?? '', style: titleStyle),
          ],
        ),
        elevation: 0,
        leading: const CommonBackButton(),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (provider.hasMultipleCoins) ...[
                    Text(
                      l10n.selectCoinTitle,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _CoinSelector(
                      coins: provider.coins,
                      selectedCoin: selectedCoin,
                      onCoinSelected: (coin) {
                        context.read<QrCodeProvider>().selectCoin(coin);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                  Text(
                    l10n.qrCodeLabel,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RepaintBoundary(
                    key: provider.qrBoundaryKey,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: currentAddress?.isEmpty == true
                            ? SizedBox.square(
                                dimension: 200,
                                child: Center(
                                  child: Text(
                                    l10n.noAddressFound,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: colorScheme.onSurface,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ),
                              )
                            : QrImageView(
                                data: currentAddress!,
                                version: QrVersions.auto,
                                size: 280,
                                backgroundColor: Colors.white,
                                eyeStyle: const QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: Colors.black,
                                ),
                                dataModuleStyle: const QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: Colors.black,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _onSaveImageTap(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.surfaceContainerHigh,
                      foregroundColor: colorScheme.onSurface,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.saveImage,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        context.read<QrCodeProvider>().shareImage(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.tealColor,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.shareAction,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onSaveImageTap(BuildContext context) {
    final provider = context.read<QrCodeProvider>();
    final l10n = context.l10n!;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ImageSaveAsBottomSheet(
        onSave: (format) async {
          await provider.saveImage(context, format);
          if (context.mounted) {
            SnackbarHelper.showSuccess(context, l10n.imageSavedSuccessfully);
          }
        },
      ),
    );
  }
}

/// Coin selector styled like the send/swap module — a tappable container
/// that opens a bottom sheet with the list of available coins.
class _CoinSelector extends StatelessWidget {
  const _CoinSelector({
    required this.coins,
    required this.selectedCoin,
    required this.onCoinSelected,
  });

  final List<WalletCoinModel> coins;
  final WalletCoinModel? selectedCoin;
  final ValueChanged<WalletCoinModel> onCoinSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final coin = selectedCoin;

    return GestureDetector(
      onTap: () => _showCoinSelectionSheet(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _fieldBoxDecoration(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  if (coin != null) ...[
                    CommonCoinIcon(
                      symbol: coin.symbol,
                      radius: 20,
                      networkIconUrl: coin.networkIconUrl,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            coin.name,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            coin.symbol,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else
                    Text(
                      context.l10n!.selectCoinTitle,
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  void _showCoinSelectionSheet(BuildContext context) {
    final l10n = context.l10n!;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: IconButton(
                      icon: Icon(Icons.close, color: colorScheme.onSurface),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Text(
                    l10n.selectCoinTitle,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: coins.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final coin = coins[index];
                  final isSelected = coin == selectedCoin;

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: isSelected
                          ? Border.all(color: AppColors.tealColor)
                          : null,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: CommonCoinIcon(
                        symbol: coin.symbol,
                        networkIconUrl: coin.networkIconUrl,
                      ),
                      title: Text(
                        coin.name,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        coin.symbol,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      onTap: () {
                        onCoinSelected(coin);
                        Navigator.of(context).pop();
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  BoxDecoration _fieldBoxDecoration(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (context.isDarkMode) {
      return BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      );
    }
    return BoxDecoration(
      color: AppColors.lightSurface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.sendFormFieldBorderLight),
    );
  }
}
