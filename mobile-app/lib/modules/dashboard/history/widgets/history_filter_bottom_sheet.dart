import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/custom_date_picker_dialog.dart';

class HistoryFilterBottomSheet extends StatefulWidget {
  const HistoryFilterBottomSheet({
    super.key,
    required this.selectedStatus,
    required this.dateStart,
    required this.dateEnd,
    required this.onApply,
  });

  final String? selectedStatus;
  final DateTime? dateStart;
  final DateTime? dateEnd;
  final void Function({
    String? status,
    DateTime? dateStart,
    DateTime? dateEnd,
  })
  onApply;

  static void show(
    BuildContext context, {
    required String? selectedStatus,
    required DateTime? dateStart,
    required DateTime? dateEnd,
    required void Function({
      String? status,
      DateTime? dateStart,
      DateTime? dateEnd,
    })
    onApply,
  }) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      showDragHandle: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      elevation: 5,
      builder: (context) => HistoryFilterBottomSheet(
        selectedStatus: selectedStatus,
        dateStart: dateStart,
        dateEnd: dateEnd,
        onApply: onApply,
      ),
    );
  }

  @override
  State<HistoryFilterBottomSheet> createState() =>
      _HistoryFilterBottomSheetState();
}

class _HistoryFilterBottomSheetState extends State<HistoryFilterBottomSheet> {
  late String? _selectedStatus;
  late DateTime? _dateStart;
  late DateTime? _dateEnd;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.selectedStatus;
    _dateStart = widget.dateStart;
    _dateEnd = widget.dateEnd;
  }

  void _handleReset() {
    setState(() {
      _selectedStatus = null;
      _dateStart = null;
      _dateEnd = null;
    });
  }

  void _handleApply() {
    widget.onApply(
      status: _selectedStatus,
      dateStart: _dateStart,
      dateEnd: _dateEnd,
    );
    Navigator.of(context).pop();
  }

  Future<void> _pickDateStart() async {
    final picked = await CustomDatePickerDialog.show(
      context,
      title: context.l10n!.dateFrom,
      initialDate: _dateStart ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() => _dateStart = picked);
    }
  }

  Future<void> _pickDateEnd() async {
    final initial = _dateEnd ?? _dateStart ?? DateTime.now();
    final picked = await CustomDatePickerDialog.show(
      context,
      title: context.l10n!.dateTo,
      initialDate: initial,
      firstDate: _dateStart ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() => _dateEnd = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final textColor =
        theme.textTheme.bodyMedium?.color ?? AppColors.textLightGrey;
    final labelColor = AppColors.textLightGrey;

    final statusOptions = <String?>[
      null,
      'COMPLETED',
      'PENDING',
    ];

    String getStatusLabel(String? status) {
      if (status == null) return l10n.all;
      switch (status.toUpperCase()) {
        case 'COMPLETED':
          return l10n.completed;
        case 'PENDING':
          return l10n.pending;
        case 'FAILED':
          return l10n.failed;
        default:
          return status;
      }
    }

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      elevation: 5,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: Filter title + close button
              Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    l10n.filter,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 18,
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: IconButton(
                      icon: Icon(
                        CupertinoIcons.xmark,
                        color: textColor,
                        size: 24,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Status section
              Text(
                l10n.transactionType,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: labelColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (int i = 0; i < statusOptions.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(
                      child: _FilterChip(
                        label: getStatusLabel(statusOptions[i]),
                        isSelected: _selectedStatus == statusOptions[i],
                        onTap: () {
                          setState(
                            () => _selectedStatus = statusOptions[i],
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),

              // Date section
              Text(
                l10n.date,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: labelColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      hint: l10n.dateStart,
                      value: _dateStart,
                      onTap: _pickDateStart,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateField(
                      hint: l10n.dateEnd,
                      value: _dateEnd,
                      onTap: _pickDateEnd,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Reset and Apply buttons
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: l10n.reset,
                      isPrimary: false,
                      onPressed: _handleReset,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      label: l10n.apply,
                      isPrimary: true,
                      onPressed: _handleApply,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final chipBg = isDarkMode
        ? AppColors.darkCardColor
        : const Color(0xFFF5F5F5);
    final textColor = isSelected
        ? (isDarkMode ? AppColors.white : AppColors.textBlack)
        : AppColors.textLightGrey;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: chipBg,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.primaryColor, width: 1.5)
              : Border.all(color: AppColors.divider, width: 1.5),
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textColor,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.hint,
    required this.value,
    required this.onTap,
  });

  final String hint;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final chipBg = isDarkMode
        ? AppColors.darkCardColor
        : const Color(0xFFF5F5F5);
    final textColor = value != null
        ? (isDarkMode ? AppColors.white : AppColors.textBlack)
        : AppColors.textLightGrey;

    String displayText = value != null
        ? '${value!.year}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}'
        : hint;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: chipBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode
                ? AppColors.textGrey.withValues(alpha: 0.3)
                : const Color(0xFFE8E8E8),
            width: 1,
          ),
        ),
        child: Text(
          displayText,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.isPrimary,
    required this.onPressed,
  });

  final String label;
  final bool isPrimary;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    if (isPrimary) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: isDarkMode
            ? AppColors.darkCardColor
            : const Color(0xFFE8E8E8),
        foregroundColor:
            theme.textTheme.bodyMedium?.color ?? AppColors.textBlack,
        side: BorderSide(
          color: isDarkMode ? AppColors.textGrey : const Color(0xFFE8E8E8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
