import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/app_exception.dart';
import '../../../core/utils/date_time_format.dart';
import '../../../widgets/common_back_button.dart';
import '../../../widgets/common_loading_indicator.dart';
import '../models/support_request_detail_model.dart';
import '../models/support_request_model.dart';
import '../providers/request_detail_provider.dart';

DateTime? _latestAdminResponseDate(List<SupportRequestResponse> responses) {
  DateTime? latest;
  for (final r in responses) {
    if (!r.isAdminResponse) continue;
    if (latest == null || r.createdAt.isAfter(latest)) latest = r.createdAt;
  }
  return latest;
}

String? _ticketIdFromId(String? id) {
  if (id == null || id.isEmpty) return null;
  final first = id.split('-').first;
  return first.isEmpty ? null : first.toUpperCase();
}

class RequestDetailView extends StatelessWidget {
  const RequestDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = Theme.of(context);

    return Consumer<RequestDetailProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CommonLoadingIndicator());
        }

        if (provider.errorKey != null && provider.detail == null) {
          return _ErrorView(
            message:
                AppException.resolveErrorKey(l10n, provider.errorKey!) ??
                l10n.somethingWentWrong,
            onRetry: () => provider.fetchDetail(),
          );
        }

        final detail = provider.detail;
        if (detail == null) {
          return const Center(child: CommonLoadingIndicator());
        }

        return Scaffold(
          appBar: AppBar(
            leading: CommonBackButton(
              onPressed: () => GoRouter.of(context).pop(),
            ),
            title: Text(
              l10n.pastRequests,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              Consumer<RequestDetailProvider>(
                builder: (context, provider, _) {
                  final detail = provider.detail;
                  final ticketId =
                      detail?.ticketId ?? _ticketIdFromId(detail?.id);
                  if (ticketId == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: 16),
                    child: Center(
                      child: Text(
                        '#$ticketId',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textLightGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              _StatusBanner(
                status: detail.status,
                statusColor: detail.statusColor,
                statusChangedAt: _latestAdminResponseDate(detail.responses),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primaryColor,
                  onRefresh: () => provider.fetchDetail(isRefresh: true),

                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: ClampingScrollPhysics(),
                    ),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(16.0),
                        sliver: SliverFillRemaining(
                          hasScrollBody: false,
                          child: _RequestContent(detail: detail),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Re-opening is only supported for solved tickets — hide the whole
          // section for guests and for open/rejected/other statuses.
          bottomSheet:
              provider.isGuest || detail.status != SupportRequestStatus.solved
              ? null
              : _BottomBar(
                  onReopen: () async {
                    // Collect the reopen reason/attachment on a dedicated form
                    // screen, then refresh the detail if it was reopened.
                    final reopened = await GoRouter.of(context).pushNamed<bool>(
                      'reopenRequest',
                      extra: provider.requestId,
                    );
                    if (reopened == true && context.mounted) {
                      await provider.fetchDetail();
                    }
                  },
                ),
        );
      },
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final SupportRequestStatus status;
  final String? statusColor;
  final DateTime? statusChangedAt;

  const _StatusBanner({
    required this.status,
    this.statusColor,
    this.statusChangedAt,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final color = _getBannerColor();
    final statusText = _getStatusText(l10n);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getStatusLabel(l10n),
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(dynamic l10n) {
    switch (status) {
      case SupportRequestStatus.open:
      case SupportRequestStatus.pending:
        return l10n.inReview as String;
      case SupportRequestStatus.solved:
        return statusChangedAt != null
            ? l10n.solutionSentOn(statusChangedAt!.toAppDateTime()) as String
            : l10n.resolvedStatus as String;
      case SupportRequestStatus.rejected:
        return statusChangedAt != null
            ? l10n.rejectionSentOn(statusChangedAt!.toAppDateTime()) as String
            : l10n.rejectedStatus as String;
    }
  }

  String _getStatusLabel(dynamic l10n) {
    switch (status) {
      case SupportRequestStatus.open:
      case SupportRequestStatus.pending:
        return l10n.open as String;
      case SupportRequestStatus.solved:
        return l10n.solved as String;
      case SupportRequestStatus.rejected:
        return l10n.rejected as String;
    }
  }

  Color _getBannerColor() {
    if (statusColor != null) {
      switch (statusColor) {
        case 'green':
          return AppColors.primaryColor;
        case 'red':
          return AppColors.statusRejectedRed;
        case 'yellow':
          return AppColors.statusInReviewOrange;
        case 'blue':
          return Colors.blue;
      }
    }
    switch (status) {
      case SupportRequestStatus.solved:
        return AppColors.primaryColor;
      case SupportRequestStatus.rejected:
        return AppColors.statusRejectedRed;
      case SupportRequestStatus.open:
      case SupportRequestStatus.pending:
        return AppColors.statusInReviewOrange;
    }
  }
}

class _RequestContent extends StatelessWidget {
  final SupportRequestDetailModel detail;

  const _RequestContent({required this.detail});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<RequestDetailProvider>();
    final items = <_TimelineItemData>[
      _TimelineItemData(
        id: RequestDetailProvider.requestItemId,
        title: detail.title,
        body: detail.description,
        createdAt: detail.createdAt,
        attachments: detail.attachments,
        isAdmin: false,
      ),
      ...detail.responses.map(
        (response) => _TimelineItemData(
          id: response.id,
          title: response.isAdminResponse
              ? context.l10n!.supportTeamReply
              : context.l10n!.yourReply,
          body: response.message,
          createdAt: response.createdAt,
          attachments: response.attachments,
          isAdmin: response.isAdminResponse,
        ),
      ),
      // Show the newest entry first so the latest reply sits at the top.
    ].reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        for (var i = 0; i < items.length; i++)
          _TimelineItem(
            data: items[i],
            isLast: i == items.length - 1,
            provider: provider,
          ),
      ],
    );
  }
}

class _TimelineItemData {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final List<SupportRequestAttachment> attachments;
  final bool isAdmin;

  const _TimelineItemData({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.attachments,
    required this.isAdmin,
  });
}

class _TimelineItem extends StatelessWidget {
  final _TimelineItemData data;
  final bool isLast;
  final RequestDetailProvider provider;

  const _TimelineItem({
    required this.data,
    required this.isLast,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isExpanded = provider.isItemExpanded(data.id);
    final iconBg = data.isAdmin ? AppColors.greenColor : AppColors.primaryColor;
    final iconData = data.isAdmin
        ? Icons.check_rounded
        : Icons.description_outlined;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(iconData, color: Colors.white, size: 18),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => provider.toggleItemExpansion(data.id),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: isDark
                                        ? AppColors.textWhite
                                        : AppColors.textBlack,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.createdOn(
                                    data.createdAt.toAppDateTime(),
                                  ),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textLightGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textLightGrey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isExpanded && data.body.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.body,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? AppColors.textWhite
                                  : AppColors.textBlack,
                              height: 1.5,
                            ),
                          ),
                          if (data.attachments.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            ...data.attachments.map(
                              (attachment) => _AttachmentRow(
                                attachment: attachment,
                                provider: provider,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentRow extends StatelessWidget {
  final SupportRequestAttachment attachment;
  final RequestDetailProvider provider;

  const _AttachmentRow({required this.attachment, required this.provider});

  bool get _isImage {
    final url = attachment.url.toLowerCase();
    return url.endsWith('.png') ||
        url.endsWith('.jpg') ||
        url.endsWith('.jpeg');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fileName = provider.extractFileName(attachment.url);
    final fileSize = provider.getFileSizeForUrl(attachment.url);

    return InkWell(
      onTap: () => _openAttachment(attachment.url),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              _isImage ? Icons.image_outlined : Icons.attach_file,
              color: AppColors.textLightGrey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                fileName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.textWhite : AppColors.textBlack,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (fileSize != null)
              Text(
                provider.formatFileSize(fileSize),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textLightGrey,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAttachment(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _BottomBar extends StatelessWidget {
  final VoidCallback onReopen;

  const _BottomBar({required this.onReopen});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF364153) : Colors.grey.shade300,
            width: 1.11,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          17,
          16,
          context.mediaQueryViewPadding.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.issueNotResolved,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textLightGrey,
              ),
            ),
            const SizedBox(height: 12),
            _ReopenButton(onReopen: onReopen, label: l10n.reopenTicket),
          ],
        ),
      ),
    );
  }
}

class _ReopenButton extends StatelessWidget {
  final VoidCallback onReopen;
  final String label;

  const _ReopenButton({required this.onReopen, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onReopen,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF2AA29A), Colors.white],
          ),
        ),
        padding: const EdgeInsets.all(1),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: const Color(0xFF2AA29A),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textLightGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: Text(
                context.l10n!.retry,
                style: TextStyle(color: AppColors.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
