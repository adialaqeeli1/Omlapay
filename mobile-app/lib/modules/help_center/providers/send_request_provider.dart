import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../../core/services/device_identifier_service.dart';
import '../../../core/utils/app_exception.dart';
import '../../../providers/auth_provider.dart';
import '../services/help_center_service.dart';

class SendRequestProvider extends ChangeNotifier {
  final HelpCenterService _service;
  final AuthProvider _authProvider;

  SendRequestProvider(
    this._authProvider, {
    HelpCenterService? service,
  }) : _service = service ?? HelpCenterService();

  bool get isGuest => !_authProvider.state.isAuthenticated;

  final FormGroup form = FormGroup({
    'title': FormControl<String>(
      validators: [Validators.required, Validators.maxLength(50)],
    ),
    'description': FormControl<String>(
      validators: [Validators.required, Validators.maxLength(200)],
    ),
  });

  PlatformFile? _selectedFile;
  bool _isSending = false;
  String? _errorKey;

  PlatformFile? get selectedFile => _selectedFile;
  bool get isSending => _isSending;
  String? get errorKey => _errorKey;

  FormControl<String> get titleControl =>
      form.control('title') as FormControl<String>;
  FormControl<String> get descriptionControl =>
      form.control('description') as FormControl<String>;

  static const List<String> allowedExtensions = ['png', 'jpg', 'pdf'];

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );

    if (result != null && result.files.single.path != null) {
      _selectedFile = result.files.single;
      notifyListeners();
    }
  }

  Future<bool> send() async {
    form.markAllAsTouched();
    if (!form.valid) return false;

    _isSending = true;
    _errorKey = null;
    notifyListeners();

    try {
      String? attachmentUrl;
      String? macAddress;

      if (isGuest) {
        // Guests can't upload files (auth-only endpoint) — skip upload and
        // send the request to the guest endpoint with a device identifier.
        macAddress = await DeviceIdentifierService.instance
            .getDeviceIdentifier();
      } else if (_selectedFile?.path != null) {
        attachmentUrl = await _service.uploadFile(
          filePath: _selectedFile!.path!,
          fileName: _selectedFile!.name,
        );
      }

      await _service.submitRequest(
        title: titleControl.value!.trim(),
        description: descriptionControl.value!.trim(),
        attachmentUrl: attachmentUrl,
        macAddress: macAddress,
      );

      return true;
    } on AppException catch (e) {
      _errorKey = e.messageKey ?? 'requestFailed';
      return false;
    } catch (_) {
      _errorKey = 'somethingWentWrong';
      return false;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }
}
