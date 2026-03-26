import 'package:flutter/material.dart';
import '../../../../../core/extentions/context_extensions.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../widgets/common_bottom_sheet.dart';

enum FilterOption { all, solved, pending, rejected }

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  FilterOption _selectedOption = FilterOption.all;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = Theme.of(context);
    final textColor =
        theme.textTheme.bodyMedium?.color ?? AppColors.textLightGrey;

    final options = [
      FilterOption.all,
      FilterOption.solved,
      FilterOption.pending,
      FilterOption.rejected,
    ];

    String getOptionLabel(FilterOption option) {
      switch (option) {
        case FilterOption.all:
          return l10n.all;
        case FilterOption.solved:
          return l10n.solved;
        case FilterOption.pending:
          return l10n.pending;
        case FilterOption.rejected:
          return l10n.rejected;
      }
    }

    return CommonBottomSheet(
      title: l10n.filter,
      childrens: [
        RadioGroup<FilterOption>(
          groupValue: _selectedOption,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedOption = value;
              });
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              return ListTile(
                onTap: () {
                  setState(() {
                    _selectedOption = option;
                  });
                  // You can add callback here if needed
                  // Navigator.of(context).pop();
                },
                title: Text(
                  getOptionLabel(option),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Radio<FilterOption>(
                  value: option,
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
          ),
        ),
      ],
    );
  }
}
