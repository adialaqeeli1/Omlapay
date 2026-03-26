import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../widgets/common_attachment_field.dart';
import '../../../../widgets/common_back_button.dart';
import '../../../../widgets/common_button.dart';
import '../../../../widgets/common_form_label.dart';
import '../../../../widgets/common_text_field.dart';

class SendRequestView extends StatefulWidget {
  const SendRequestView({super.key});

  @override
  State<SendRequestView> createState() => _SendRequestViewState();
}

class _SendRequestViewState extends State<SendRequestView> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  PlatformFile? _selectedFile;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = result.files.single;
        });
      }
    } catch (e) {
      if (mounted) {
        final loc = context.l10n!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.errorPickingFile('$e'))),
        );
      }
    }
  }

  void _handleSend() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement send request logic
      final loc = context.l10n!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.helpRequestSentSuccess)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.05;

    return Scaffold(
      appBar: AppBar(
        leading: CommonBackButton(onPressed: () => GoRouter.of(context).pop()),
        title: Text(
          l10n.sendRequest,
          style: theme.textTheme.titleLarge?.copyWith(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              // Title field
              CommonFormLabel(label: l10n.title),
              const SizedBox(height: 8),
              CommonTextField(
                controller: _titleController,
                hintText: l10n.titlePlaceholder,
                maxLength: 50,
                showCharacterCount: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  if (value.length > 50) {
                    return 'Title must not exceed 50 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Description field
              CommonFormLabel(label: l10n.description),
              const SizedBox(height: 8),
              CommonTextField(
                controller: _descriptionController,
                hintText: l10n.descriptionPlaceholder,
                maxLines: 5,
                maxLength: 200,
                showCharacterCount: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  if (value.length > 200) {
                    return 'Description must not exceed 200 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Attachment field
              CommonFormLabel(label: l10n.attachment),
              const SizedBox(height: 8),
              CommonAttachmentField(
                onTap: _pickFile,
                selectedFile: _selectedFile,
                placeholder: l10n.attachFileDescription,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              // Send button
              CommonButton(onPressed: _handleSend, title: l10n.send),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}
