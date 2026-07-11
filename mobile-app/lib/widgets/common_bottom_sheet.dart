import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../core/theme/theme.dart';

class CommonBottomSheet extends StatefulWidget {
  const CommonBottomSheet({
    super.key,
    required this.title,
    required this.childrens,
    this.showDivider = true,
  });

  final String title;
  final List<Widget> childrens;
  final bool showDivider;

  @override
  State<CommonBottomSheet> createState() => _CommonBottomSheetState();
}

class _CommonBottomSheetState extends State<CommonBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor =
        theme.textTheme.bodyMedium?.color ?? AppColors.textLightGrey;
    return BottomSheet(
      onClosing: () {},
      animationController: _animationController,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 20,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(
                top: 16,
                start: 8,
                end: 8,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: IconButton(
                      icon: Icon(Icons.close, color: textColor, size: 30),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),

            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: widget.childrens
                    .mapIndexed(
                      (index, e) => DecoratedBox(
                        decoration: BoxDecoration(
                          border: widget.showDivider == false
                              ? null
                              : (widget.childrens.last == e
                                    ? null
                                    : Border(
                                        bottom: BorderSide(
                                          color:
                                              theme.dividerTheme.color ??
                                              const Color(0xFF4F4F4F),
                                        ),
                                      )),
                        ),
                        child: e,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
