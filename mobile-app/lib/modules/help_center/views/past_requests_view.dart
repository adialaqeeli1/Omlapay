import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../core/theme/theme.dart';
import '../../../widgets/common_back_button.dart';
import '../../../widgets/common_loading_indicator.dart';
import '../../../widgets/paginated_list_view.dart';
import '../models/support_request_model.dart';
import '../providers/help_center_provider.dart';
import '../widgets/filter_bottom_sheet.dart';

class PastRequestsView extends StatefulWidget {
  const PastRequestsView({super.key});

  @override
  State<PastRequestsView> createState() => _PastRequestsViewState();
}

class _PastRequestsViewState extends State<PastRequestsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HelpCenterProvider>().fetchRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: CommonBackButton(onPressed: () => GoRouter.of(context).pop()),
        title: Text(
          l10n.pastRequests,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/filter-icon.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                theme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              FilterBottomSheet.show(context);
            },
          ),
        ],
      ),
      body: Consumer<HelpCenterProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CommonLoadingIndicator());
          }

          if (provider.errorMessage != null && provider.items.isEmpty) {
            return _ErrorView(
              message: provider.errorMessage!,
              onRetry: () => provider.fetchRequests(),
            );
          }

          if (provider.items.isEmpty) {
            return _EmptyView();
          }

          final sectionWidgets = _buildSections(provider.items, l10n);

          return PaginatedListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: sectionWidgets.length,
            isLoadingMore: provider.isLoadingMore,
            hasMore: provider.hasMore,
            onLoadMore: () => provider.loadMore(),
            itemBuilder: (context, index) => sectionWidgets[index],
          );
        },
      ),
    );
  }

  List<Widget> _buildSections(List<SupportRequestModel> items, dynamic l10n) {
    final now = DateTime.now();
    final sections = <Widget>[];
    String? currentSection;

    for (final item in items) {
      final localDate = item.createdAt.toLocal();
      final sectionLabel = _getSectionLabel(localDate, now, l10n);

      if (sectionLabel != currentSection) {
        currentSection = sectionLabel;
        sections.add(_SectionHeader(title: sectionLabel));
      }

      sections.add(_RequestItem(request: item));
    }

    return sections;
  }

  String _getSectionLabel(DateTime date, DateTime now, dynamic l10n) {
    final difference = now.difference(date);

    if (difference.inDays <= 7) {
      return l10n.recently as String;
    }

    return DateFormat('MMMM, yyyy').format(date);
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.textLightGrey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _RequestItem extends StatelessWidget {
  final SupportRequestModel request;

  const _RequestItem({required this.request});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: isDark ? AppColors.textWhite : AppColors.textBlack,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat(
                    'yyyy-MM-dd HH:mm:ss',
                  ).format(request.createdAt.toLocal()),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textLightGrey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              _getStatusLabel(request.status, l10n),
              style: TextStyle(
                color: _getStatusColor(request.status, request.statusColor),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(SupportRequestStatus status, dynamic l10n) {
    switch (status) {
      case SupportRequestStatus.open:
        return l10n.open as String;
      case SupportRequestStatus.pending:
        return l10n.pending as String;
      case SupportRequestStatus.solved:
        return l10n.solved as String;
      case SupportRequestStatus.rejected:
        return l10n.rejected as String;
    }
  }

  Color _getStatusColor(SupportRequestStatus status, String? statusColor) {
    if (statusColor != null) {
      switch (statusColor) {
        case 'green':
          return Colors.green;
        case 'red':
          return Colors.red;
        case 'yellow':
          return Colors.orange;
        case 'blue':
          return Colors.blue;
      }
    }
    switch (status) {
      case SupportRequestStatus.solved:
        return Colors.green;
      case SupportRequestStatus.rejected:
        return Colors.red;
      case SupportRequestStatus.open:
      case SupportRequestStatus.pending:
        return Colors.orange;
    }
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = Theme.of(context);

    return Center(
      child: Transform.translate(
        offset: Offset(0, -MediaQuery.of(context).size.height * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              theme.brightness == Brightness.dark
                  ? 'assets/icons/empty-state-dark.svg'
                  : 'assets/icons/empty-state-light.svg',
              width: 250,
              height: 200,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Text(
              l10n.noRequestsFound,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.brightness == Brightness.dark
                    ? AppColors.textWhite
                    : AppColors.textBlack,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Text(
              l10n.allRequestsWillBeListedHere,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textLightGrey,
                fontSize: 18,
              ),
            ),
          ],
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
