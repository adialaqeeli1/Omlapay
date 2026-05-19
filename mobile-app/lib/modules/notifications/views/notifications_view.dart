import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/models/notification/notification_model.dart';
import '../../../core/theme/theme.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/common_back_button.dart';
import '../../../widgets/common_loading_indicator.dart';
import '../../../widgets/paginated_list_view.dart';
import '../providers/notifications_provider.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: CommonBackButton(
          onPressed: context.canPop()
              ? null
              : () => context.pushReplacement(Routes.home),
        ),
        title: Text(
          l10n.notifications,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<NotificationsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CommonLoadingIndicator());
          }

          if (provider.errorKey != null && provider.items.isEmpty) {
            return _buildErrorState(l10n, provider, isDark);
          }

          if (provider.items.isEmpty) {
            return _buildEmptyState(l10n, isDark);
          }

          return Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSummaryBar(
                    context,
                    l10n,
                    provider.unreadCount,
                    provider.markAllAsRead,
                    isDark,
                  ),
                  Expanded(
                    child: PaginatedListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: provider.items.length,
                      isLoadingMore: provider.isLoadingMore,
                      hasMore: provider.hasMore,
                      onLoadMore: provider.loadMore,
                      itemBuilder: (context, index) {
                        final item = provider.items[index];
                        return _NotificationTile(
                          item: item,
                          isDark: isDark,
                          // onTap: () => provider.markAsRead(item.id),
                        );
                      },
                    ),
                  ),
                ],
              ),
              if (provider.isActionLoading)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black26,
                    child: const Center(child: CommonLoadingIndicator()),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorState(
    AppLocalizations l10n,
    NotificationsProvider provider,
    bool isDark,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: isDark ? AppColors.textLightGrey : AppColors.textGrey,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.notificationsLoadError,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.textLightGrey : AppColors.textGrey,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: provider.fetchNotifications,
              child: Text(
                l10n.retry,
                style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          l10n.noNotifications,
          style: TextStyle(
            color: isDark ? AppColors.textLightGrey : AppColors.textGrey,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryBar(
    BuildContext context,
    AppLocalizations l10n,
    int unreadCount,
    VoidCallback onMarkAllRead,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            unreadCount == 1
                ? l10n.unreadNotification
                : l10n.unreadNotifications(unreadCount),
            style: TextStyle(
              color: isDark ? AppColors.textWhite : AppColors.textBlack,
              fontSize: 14,
            ),
          ),
          if (unreadCount > 0)
            GestureDetector(
              onTap: onMarkAllRead,
              child: Text(
                l10n.markAsRead,
                style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel item;
  final bool isDark;
  final VoidCallback? onTap;

  const _NotificationTile({
    required this.item,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.textWhite : AppColors.textBlack;
    final subColor = isDark ? AppColors.textLightGrey : AppColors.textGrey;
    final readOpacity = item.isRead ? 0.5 : 1.0;
    final iconInfo = _iconForItem(item);

    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Opacity(
          opacity: readOpacity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconInfo.$2,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: iconInfo.$1,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? (item.titleAr ?? item.title) : item.title,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: item.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAr ? (item.messageAr ?? item.message) : item.message,
                      style: TextStyle(
                        color: subColor,
                        fontWeight: item.isRead
                            ? FontWeight.normal
                            : FontWeight.w500,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _RelativeTimeText(
                date: item.createdAt,
                style: TextStyle(color: subColor, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const Color _txBgColor = Color(0xFF2196F3);

  (Widget, Color) _iconForItem(NotificationModel item) {
    switch (item.type) {
      case NotificationType.tx:
        final title = item.title.trim().toLowerCase();
        if (title.contains('sent')) {
          return (_buildTxSvg('assets/icons/send.svg'), _txBgColor);
        }
        if (title.contains('receiv')) {
          return (_buildTxSvg('assets/icons/Receive.svg'), _txBgColor);
        }
        return (
          const Icon(Icons.swap_horiz, color: Colors.white, size: 24),
          _txBgColor,
        );
      case NotificationType.security:
        return (
          const Icon(Icons.security, color: Colors.white, size: 24),
          const Color(0xFFE53935),
        );
      case NotificationType.promo:
        return (
          const Icon(Icons.local_offer, color: Colors.white, size: 24),
          const Color(0xFF9C27B0),
        );
      case NotificationType.system:
        return (
          const Icon(Icons.info_outline, color: Colors.white, size: 24),
          AppColors.primaryColor,
        );
    }
  }

  Widget _buildTxSvg(String asset) {
    return SvgPicture.asset(
      asset,
      width: 20,
      height: 20,
      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
    );
  }
}

class _RelativeTimeText extends StatefulWidget {
  final DateTime date;
  final TextStyle? style;

  const _RelativeTimeText({required this.date, this.style});

  @override
  State<_RelativeTimeText> createState() => _RelativeTimeTextState();
}

class _RelativeTimeTextState extends State<_RelativeTimeText> {
  Stream<void>? _tickStream;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  @override
  void didUpdateWidget(_RelativeTimeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.date != widget.date) {
      _initStream();
    }
  }

  void _initStream() {
    final difference = DateTime.now().difference(widget.date);
    _tickStream = difference.inDays < 7
        ? Stream.periodic(const Duration(seconds: 1))
        : null;
  }

  @override
  Widget build(BuildContext context) {
    if (_tickStream == null) {
      return Text(DateFormat('d MMM').format(widget.date), style: widget.style);
    }

    return StreamBuilder<void>(
      stream: _tickStream,
      builder: (context, _) {
        return Text(_formatDate(widget.date), style: widget.style);
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m';
      }
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    }

    return DateFormat('d MMM').format(date);
  }
}
