import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/theme.dart';

class CommonTextField extends StatelessWidget {
  const CommonTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.labelText,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.obscureText = false,
    this.maxLines = 1,
    this.enabled = true,
    this.maxLength,
    this.showCharacterCount = false,
    this.prefixIcon,
    this.suffixIcon,
    this.fillColor,
    this.contentPadding,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.textDirection,
    this.textAlign = TextAlign.start,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final String? labelText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final int maxLines;
  final bool enabled;
  final int? maxLength;
  final bool showCharacterCount;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;

  /// Forces a writing direction for the input content (e.g.
  /// [TextDirection.ltr] for phone numbers so digits/`+` aren't reordered
  /// under an RTL locale). Null follows the ambient direction.
  final TextDirection? textDirection;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          validator: validator,
          onChanged: onChanged,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textDirection: textDirection,
          textAlign: textAlign,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          maxLines: maxLines,
          enabled: enabled,
          maxLength: maxLength,
          onTapOutside: (event) => FocusScope.of(context).unfocus(),
          style: TextStyle(
            color: isDark ? AppColors.textWhite : AppColors.textBlack,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: isDark ? AppColors.textLightGrey : AppColors.textGrey,
              fontSize: 16,
            ),
            filled: true,
            fillColor:
                fillColor ?? (isDark ? Colors.grey[900] : Colors.grey[100]),
            border:
                border ??
                OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
            enabledBorder: enabledBorder,
            focusedBorder: focusedBorder,
            contentPadding:
                contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            counterText: '', // Hide default counter
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
        ),
        if (showCharacterCount && maxLength != null && controller != null)
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller!,
            builder: (context, value, child) {
              final currentLength = value.text.length;
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$currentLength/$maxLength',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textLightGrey
                          : AppColors.textGrey,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
