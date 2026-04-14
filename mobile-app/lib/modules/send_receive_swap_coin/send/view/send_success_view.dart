import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/models/coin_model/coin_model_quote_display.dart';
import '../../../../core/theme/theme.dart';
import '../../../../routes/app_router.dart';
import '../../../../widgets/common_back_button.dart';
import '../provider/send_provider.dart';

class SendSuccessView extends StatefulWidget {
  const SendSuccessView({super.key});

  @override
  State<SendSuccessView> createState() => _SendSuccessViewState();
}

class _SendSuccessViewState extends State<SendSuccessView> {
  late final DateTime _fallbackExecutionTime;

  @override
  void initState() {
    super.initState();
    _fallbackExecutionTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SendProvider>();
    final l10n = context.l10n!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final confirm = provider.confirmResponse;

    final ticker = confirm?.coin.isNotEmpty ?? false
        ? confirm!.coin
        : provider.quote?.coin ??
              provider.selectedCoin?.localizedCoinTicker(context) ??
              '';
    final amount = confirm?.amount.isNotEmpty ?? false
        ? confirm!.amount
        : provider.quote?.amount ?? provider.amountController.text;

    final estimatedCompletion =
        DateTime.tryParse(confirm?.estimatedCompletion ?? '')?.toLocal() ??
            _fallbackExecutionTime;
    final formattedTime = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(estimatedCompletion);

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          label: l10n.successScreenTitle,
          child: const SizedBox.shrink(),
        ),
        elevation: 0,
        leading: CommonBackButton(onPressed: () => context.go(Routes.home)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 24),
              _SendProgressCard(
                amount: amount,
                ticker: ticker,
                statusLabel: l10n.sendInProgress,
                timeLabel: l10n.estimatedTimeOfExecution,
                formattedTime: formattedTime,
                notificationText: l10n.sendCompletionNotification,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    context.go(Routes.home);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainerHigh,
                    foregroundColor: colorScheme.onSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: Text(
                    l10n.backHome,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SendProgressCard extends StatelessWidget {
  const _SendProgressCard({
    required this.amount,
    required this.ticker,
    required this.statusLabel,
    required this.timeLabel,
    required this.formattedTime,
    required this.notificationText,
  });

  final String amount;
  final String ticker;
  final String statusLabel;
  final String timeLabel;
  final String formattedTime;
  final String notificationText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    const gradientStart = Color(0x991C1C1E);
    const gradientEnd = Color(0x991A605B);
    final gradientEndVisible =
        Color.lerp(gradientStart, gradientEnd, 0.3301) ?? gradientStart;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: const Alignment(0.75, -0.66),
          end: const Alignment(-0.75, 0.66),
          colors: [gradientStart, gradientEndVisible],
          stops: const [0.3091, 1.0],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hourglass_empty, size: 44, color: AppColors.tealColor),
          const SizedBox(height: 16),
          Text(
            statusLabel,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.tealColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$amount${ticker.isNotEmpty ? ' $ticker' : ''}',
              style: textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            timeLabel,
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            formattedTime,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            notificationText,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
