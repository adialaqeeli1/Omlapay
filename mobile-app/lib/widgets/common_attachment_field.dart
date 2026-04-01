import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../core/theme/theme.dart';

class CommonAttachmentField extends StatelessWidget {
  const CommonAttachmentField({
    super.key,
    required this.onTap,
    this.selectedFile,
    this.placeholder,
    this.allowedExtensions = const ['png', 'jpg', 'jpeg', 'pdf'],
  });

  final VoidCallback onTap;
  final PlatformFile? selectedFile;
  final String? placeholder;
  final List<String> allowedExtensions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selectedFile?.name ?? (placeholder ?? ''),
                  style: TextStyle(
                    color: selectedFile != null
                        ? (isDark ? AppColors.textWhite : AppColors.textBlack)
                        : (isDark
                              ? AppColors.textLightGrey
                              : AppColors.textGrey),
                    fontSize: 16,
                  ),
                ),
              ),
              Icon(Icons.attach_file, color: AppColors.primaryColor, size: 24),
            ],
          ),
        ),
        // if (selectedFile != null) ...[
        //   const SizedBox(height: 8),
        //   Text(
        //     selectedFile!.name,
        //     style: TextStyle(color: AppColors.primaryColor, fontSize: 14),
        //   ),
        // ],
      ],
    );
  }
}
