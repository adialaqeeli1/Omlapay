import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/extentions/context_extensions.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/theme.dart';
import '../../widgets/common_back_button.dart';
import 'notifications_list_provider.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: const CommonBackButton(),
        title: Text(
          l10n.notifications,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<NotificationsListProvider>(
        builder: (context, provider, _) {
          final unread = provider.unreadCount;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSummaryBar(context, l10n, unread, provider.markAllAsRead, isDark),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: provider.items.length,
                  itemBuilder: (context, index) {
                    final item = provider.items[index];
                    return _NotificationTile(
                      item: item,
                      isDark: isDark,
                      onTap: () => provider.markAsRead(item.id),
                    );
                  },
                ),
              ),
            ],
          );
        },
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
  final NotificationItem item;
  final bool isDark;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.item,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.textWhite : AppColors.textBlack;
    final subColor = isDark ? AppColors.textLightGrey : AppColors.textGrey;
    final readOpacity = item.isRead ? 0.5 : 1.0;

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
                  color: item.iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(
                        color: subColor,
                        fontWeight: item.isRead ? FontWeight.normal : FontWeight.w500,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item.date,
                style: TextStyle(
                  color: subColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
