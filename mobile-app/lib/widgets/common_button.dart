import 'package:flutter/material.dart';
import '../core/extentions/context_extensions.dart';
import '../core/theme/theme.dart';

class CommonButton extends StatelessWidget {
  const CommonButton({super.key, required this.onPressed, this.title});

  final VoidCallback onPressed;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          title ?? context.l10n!.continueAction,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
