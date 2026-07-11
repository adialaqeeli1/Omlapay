import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../../core/services/device_identifier_service.dart';
import '../../../core/utils/app_exception.dart';
import '../../../providers/auth_provider.dart';
import '../services/help_center_service.dart';

/// Distinguishes the two flows that share the support-request form UI.
///
/// - [send]: create a brand-new support request (title + description + file).
/// - [reopen]: re-open an existing, resolved/rejected ticket. Reuses the same
///   form, but without a title and posting to the reopen endpoint.
enum SupportRequestFormMode { send, reopen }

class SupportRequestFormProvider extends ChangeNotifier {
  final HelpCenterService _service;
  final AuthProvider _authProvider;

  /// Which flow this form drives (send vs reopen). Controls whether the title
  /// field is shown and which endpoint [submit] hits.
  final SupportRequestFormMode mode;

  /// The ticket to re-open. Required (and only used) when [mode] is
  /// [SupportRequestFormMode.reopen].
  final String? requestId;

  SupportRequestFormProvider(
    this._authProvider, {
    this.mode = SupportRequestFormMode.send,
    this.requestId,
    HelpCenterService? service,
  }) : assert(
         mode != SupportRequestFormMode.reopen || requestId != null,
         'requestId is required when mode is reopen',
       ),
       _service = service ?? HelpCenterService() {
    form = _buildForm();
  }

  bool get isGuest => !_authProvider.state.isAuthenticated;
  bool get isReopen => mode == SupportRequestFormMode.reopen;

  late final FormGroup form;

  // The title field only exists for the send flow; the reopen flow collects
  // description (+ optional attachment) only.
  FormGroup _buildForm() {
    return FormGroup({
      if (!isReopen)
        'title': FormControl<String>(
          validators: [Validators.required, Validators.maxLength(50)],
        ),
      'description': FormControl<String>(
        validators: [Validators.required, Validators.maxLength(200)],
      ),
    });
  }

  PlatformFile? _selectedFile;
  bool _isSubmitting = false;
  AppException? _error;

  PlatformFile? get selectedFile => _selectedFile;
  bool get isSubmitting => _isSubmitting;

  /// The last submit failure. Carries the server-provided, locale-aware
  /// message (when available) so the UI can show it via [AppException
  /// .localizedMessage] instead of a generic key.
  AppException? get error => _error;

  FormControl<String>? get titleControl => form.contains('title')
      ? form.control('title') as FormControl<String>
      : null;
  FormControl<String> get descriptionControl =>
      form.control('description') as FormControl<String>;

  static const List<String> allowedExtensions = ['png', 'jpg', 'pdf'];

  Future<void> pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );

    if (result != null && result.files.single.path != null) {
      _selectedFile = result.files.single;
      notifyListeners();
    }
  }

  /// Submits the form. Routes to the create endpoint in [send] mode and the
  /// reopen endpoint in [reopen] mode. Returns `true` on success.
  Future<bool> submit() async {
    form.markAllAsTouched();
    if (!form.valid) return false;

    _isSubmitting = true;
    _error = null;
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

      if (isReopen) {
        await _service.reopenRequest(
          requestId!,
          description: descriptionControl.value!.trim(),
          attachmentUrl: attachmentUrl,
        );
      } else {
        await _service.submitRequest(
          title: titleControl!.value!.trim(),
          description: descriptionControl.value!.trim(),
          attachmentUrl: attachmentUrl,
          macAddress: macAddress,
        );
      }

      return true;
    } on AppException catch (e) {
      // Keep the full exception so the UI can surface the server's
      // locale-aware `message` / `message_ar` instead of a generic key.
      _error = e;
      return false;
    } catch (_) {
      _error = AppException('', messageKey: 'somethingWentWrong');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }
}
