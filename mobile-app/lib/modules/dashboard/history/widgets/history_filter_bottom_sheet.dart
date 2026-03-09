import 'package:flutter/material.dart';
import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/models/transaction_model/transaction_model.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/common_bottom_sheet.dart';

class HistoryFilterBottomSheet extends StatefulWidget {
  const HistoryFilterBottomSheet({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  final TransactionType? selectedFilter;
  final ValueChanged<TransactionType?> onFilterSelected;

  static void show(
    BuildContext context, {
    required TransactionType? selectedFilter,
    required ValueChanged<TransactionType?> onFilterSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => HistoryFilterBottomSheet(
        selectedFilter: selectedFilter,
        onFilterSelected: onFilterSelected,
      ),
    );
  }

  @override
  State<HistoryFilterBottomSheet> createState() =>
      _HistoryFilterBottomSheetState();
}

class _HistoryFilterBottomSheetState extends State<HistoryFilterBottomSheet> {
  late TransactionType? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.selectedFilter;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = Theme.of(context);
    final textColor =
        theme.textTheme.bodyMedium?.color ?? AppColors.textLightGrey;

    final options = [
      null,
      TransactionType.sent,
      TransactionType.received,
      TransactionType.swap,
    ];

    String getOptionLabel(TransactionType? option) {
      if (option == null) return l10n.all;
      switch (option) {
        case TransactionType.sent:
          return l10n.sent;
        case TransactionType.received:
          return l10n.received;
        case TransactionType.swap:
          return l10n.swap;
      }
    }

    return CommonBottomSheet(
      title: l10n.filter,
      childrens: options.map((option) {
        return ListTile(
          onTap: () {
            setState(() {
              _selectedFilter = option;
            });
            widget.onFilterSelected(option);
            Navigator.of(context).pop();
          },
          title: Text(
            getOptionLabel(option),
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Radio<TransactionType?>(
            value: option,
            groupValue: _selectedFilter,
            onChanged: (value) {
              setState(() {
                _selectedFilter = value;
              });
              widget.onFilterSelected(value);
              Navigator.of(context).pop();
            },
            activeColor: AppColors.primaryColor,
            fillColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primaryColor;
              }
              return textColor.withValues(alpha: 0.3);
            }),
          ),
        );
      }).toList(),
    );
  }
}
