import 'dart:io';

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

  bool get _isImage {
    final ext = selectedFile?.extension?.toLowerCase();
    return ext == 'png' || ext == 'jpg' || ext == 'jpeg';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (selectedFile != null && selectedFile!.path != null) {
      return _buildFilePreview(isDark);
    }

    return _buildPlaceholder(isDark);
  }

  Widget _buildPlaceholder(bool isDark) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(
              placeholder ?? '',
              style: TextStyle(
                color: isDark ? AppColors.textLightGrey : AppColors.textGrey,
                fontSize: 16,
              ),
            ),
          ),
          Icon(Icons.attach_file, color: AppColors.primaryColor, size: 24),
        ],
      ),
    );
  }

  Widget _buildFilePreview(bool isDark) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          _buildThumbnail(isDark),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedFile!.name,
                  style: TextStyle(
                    color: isDark ? AppColors.textWhite : AppColors.textBlack,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (selectedFile!.size > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    _formatFileSize(selectedFile!.size),
                    style: TextStyle(
                      color: AppColors.textLightGrey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.attach_file, color: AppColors.primaryColor, size: 24),
        ],
      ),
    );
  }

  Widget _buildThumbnail(bool isDark) {
    if (_isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(selectedFile!.path!),
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildDocumentIcon(isDark),
        ),
      );
    }

    return _buildDocumentIcon(isDark);
  }

  Widget _buildDocumentIcon(bool isDark) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.insert_drive_file_outlined,
        color: AppColors.primaryColor,
        size: 24,
      ),
    );
  }
}
