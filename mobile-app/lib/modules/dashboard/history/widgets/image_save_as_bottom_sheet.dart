import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/theme/theme.dart';

enum ImageSaveFormat { png, jpg }

class ImageSaveAsBottomSheet extends StatefulWidget {
  const ImageSaveAsBottomSheet({
    super.key,
    required this.onSave,
  });

  final ValueChanged<ImageSaveFormat> onSave;

  @override
  State<ImageSaveAsBottomSheet> createState() => _ImageSaveAsBottomSheetState();
}

class _ImageSaveAsBottomSheetState extends State<ImageSaveAsBottomSheet> {
  ImageSaveFormat _selectedFormat = ImageSaveFormat.png;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final isDarkMode = context.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkCardColor : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      l10n.saveAs,
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? AppColors.white
                            : AppColors.textBlack,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      CupertinoIcons.xmark,
                      color: isDarkMode ? AppColors.white : AppColors.textBlack,
                      size: 24,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildFormatOption(
                context,
                label: l10n.png,
                format: ImageSaveFormat.png,
                isSelected: _selectedFormat == ImageSaveFormat.png,
              ),
              const SizedBox(height: 16),
              _buildFormatOption(
                context,
                label: l10n.jpg,
                format: ImageSaveFormat.jpg,
                isSelected: _selectedFormat == ImageSaveFormat.jpg,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryColor,
                        side: BorderSide(color: AppColors.primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.cancel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onSave(_selectedFormat);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.save,
                        style: const TextStyle(
                          fontSize: 16,
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

  Widget _buildFormatOption(
    BuildContext context, {
    required String label,
    required ImageSaveFormat format,
    required bool isSelected,
  }) {
    final isDarkMode = context.isDarkMode;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFormat = format;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDarkMode
              ? AppColors.darkBackground
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: context.textTheme.bodyLarge?.copyWith(
                color: isDarkMode ? AppColors.white : AppColors.textBlack,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryColor
                      : (isDarkMode
                          ? AppColors.textGrey
                          : const Color(0xFFE8E8E8)),
                  width: 2,
                ),
                color: isSelected
                    ? AppColors.primaryColor
                    : (isDarkMode ? AppColors.darkCardColor : AppColors.white),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
