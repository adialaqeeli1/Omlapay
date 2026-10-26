import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/extentions/context_extensions.dart';
import '../core/theme/theme.dart';

/// A custom date picker dialog matching the app's design with wheel-style
/// Year, Month, and Day pickers.
class CustomDatePickerDialog extends StatefulWidget {
  const CustomDatePickerDialog({
    super.key,
    required this.title,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  final String title;
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  /// Shows the custom date picker dialog and returns the selected date,
  /// or null if cancelled.
  static Future<DateTime?> show(
    BuildContext context, {
    required String title,
    required DateTime initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final first = firstDate ?? DateTime(1900);
    final last = lastDate ?? DateTime(2100);
    return showGeneralDialog<DateTime>(
      context: context,
      barrierDismissible: true,
      barrierLabel:
          MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) =>
          CustomDatePickerDialog(
        title: title,
        initialDate: initialDate,
        firstDate: first,
        lastDate: last,
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: child,
        );
      },
    );
  }

  @override
  State<CustomDatePickerDialog> createState() => _CustomDatePickerDialogState();
}

class _CustomDatePickerDialogState extends State<CustomDatePickerDialog> {
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  late List<int> _years;
  late List<int> _months;
  late List<int> _days;

  List<String> _getMonthNames(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return _months
        .map(
          (m) => DateFormat.MMMM(locale.toLanguageTag()).format(
            DateTime(2000, m),
          ),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
    _selectedDay = widget.initialDate.day;

    _years = List.generate(
      widget.lastDate.year - widget.firstDate.year + 1,
      (i) => widget.firstDate.year + i,
    );

    _updateMonths();
    _updateDays();
  }

  void _updateMonths() {
    var min = 1;
    var max = 12;
    if (_selectedYear == widget.firstDate.year) {
      min = widget.firstDate.month;
    }
    if (_selectedYear == widget.lastDate.year) {
      max = widget.lastDate.month;
    }
    if (max < min) max = min;
    _months = List.generate(max - min + 1, (i) => min + i);

    if (_selectedMonth < min) _selectedMonth = min;
    if (_selectedMonth > max) _selectedMonth = max;
  }

  void _updateDays() {
    final daysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
    var minDay = 1;
    var maxDay = daysInMonth;
    if (_selectedYear == widget.firstDate.year &&
        _selectedMonth == widget.firstDate.month) {
      minDay = widget.firstDate.day;
    }
    if (_selectedYear == widget.lastDate.year &&
        _selectedMonth == widget.lastDate.month) {
      maxDay = widget.lastDate.day;
    }
    if (maxDay < minDay) maxDay = minDay;
    _days = List.generate(maxDay - minDay + 1, (i) => minDay + i);

    if (_selectedDay < minDay) _selectedDay = minDay;
    if (_selectedDay > maxDay) _selectedDay = maxDay;
  }

  DateTime get _selectedDate =>
      DateTime(_selectedYear, _selectedMonth, _selectedDay);

  void _onSave() {
    Navigator.of(context).pop(_selectedDate);
  }

  void _onCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final dialogBg = isDarkMode ? AppColors.darkCardColor : Colors.white;
    final textColor = isDarkMode ? AppColors.textWhite : AppColors.textBlack;
    final labelColor = AppColors.textLightGrey;
    final dividerColor = theme.dividerTheme.color ?? AppColors.divider;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          constraints: const BoxConstraints(maxWidth: 340),
          decoration: BoxDecoration(
            color: dialogBg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 8, 16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: IconButton(
                        icon: Icon(
                          CupertinoIcons.xmark,
                          color: textColor,
                          size: 22,
                        ),
                        onPressed: _onCancel,
                      ),
                    ),
                  ],
                ),
              ),
              // Picker body
              SizedBox(
                height: 200,
                child: Row(
                  children: [
                    // Year column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              l10n.year,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: labelColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(
                            child: CupertinoPicker(
                              scrollController: FixedExtentScrollController(
                                initialItem: _years.indexOf(_selectedYear).clamp(
                                      0,
                                      _years.length - 1,
                                    ),
                              ),
                              itemExtent: 40,
                              selectionOverlay: _PickerSelectionOverlay(
                                color: dividerColor,
                              ),
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  _selectedYear = _years[index];
                                  _updateMonths();
                                  _updateDays();
                                });
                              },
                              children: _years.map((y) {
                                return Center(
                                  child: Text(
                                    '$y',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: textColor,
                                      fontSize: 18,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 160,
                      color: dividerColor,
                    ),
                    // Month column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              l10n.month,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: labelColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(
                            child: CupertinoPicker(
                              key: ValueKey('month-picker-$_selectedYear'),
                              scrollController: FixedExtentScrollController(
                                initialItem: _months
                                    .indexOf(_selectedMonth)
                                    .clamp(0, _months.length - 1),
                              ),
                              itemExtent: 40,
                              selectionOverlay: _PickerSelectionOverlay(
                                color: dividerColor,
                              ),
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  _selectedMonth = _months[index];
                                  _updateDays();
                                });
                              },
                              children: _getMonthNames(context).map((name) {
                                return Center(
                                  child: Text(
                                    name,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: textColor,
                                      fontSize: 18,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 160,
                      color: dividerColor,
                    ),
                    // Day column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              l10n.day,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: labelColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(
                            child: CupertinoPicker(
                              key: ValueKey(
                                'day-picker-$_selectedYear-$_selectedMonth',
                              ),
                              scrollController: FixedExtentScrollController(
                                initialItem: _days
                                    .indexOf(_selectedDay)
                                    .clamp(0, _days.length - 1),
                              ),
                              itemExtent: 40,
                              selectionOverlay: _PickerSelectionOverlay(
                                color: dividerColor,
                              ),
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  _selectedDay = _days[index];
                                });
                              },
                              children: _days.map((d) {
                                return Center(
                                  child: Text(
                                    '$d',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: textColor,
                                      fontSize: 18,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Footer divider
              Divider(height: 1, color: dividerColor),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _onCancel,
                      child: Text(
                        l10n.cancel,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Container(width: 1, height: 48, color: dividerColor),
                  Expanded(
                    child: TextButton(
                      onPressed: _onSave,
                      child: Text(
                        l10n.save,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

class _PickerSelectionOverlay extends StatelessWidget {
  const _PickerSelectionOverlay({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: color, width: 1),
          bottom: BorderSide(color: color, width: 1),
        ),
      ),
    );
  }
}
