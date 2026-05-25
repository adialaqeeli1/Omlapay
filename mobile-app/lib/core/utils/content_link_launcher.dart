import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../extentions/context_extensions.dart';
import 'snackbar_helper.dart';

/// Opens a link tapped inside rendered markdown / legal content.
///
/// - `mailto:` links open the device email app pre-filled with the support
///   subject. The body is intentionally left blank for the user to write their
///   message; any subject/body already present on the link is replaced.
/// - All other links (http/https/tel/…) open via the platform's default
///   handler, consistent with the rest of the app.
///
/// Shows a localized error snackbar when the link can't be opened.
Future<void> launchContentLink(BuildContext context, String rawUrl) async {
  final l10n = context.l10n!;
  final uri = _resolveUri(rawUrl, supportSubject: l10n.supportEmailSubject);

  if (uri == null) {
    SnackbarHelper.showError(context, l10n.couldNotOpenLink);
    return;
  }

  var launched = false;
  try {
    launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
  } catch (_) {
    launched = false;
  }

  if (!launched && context.mounted) {
    SnackbarHelper.showError(context, l10n.couldNotOpenLink);
  }
}

/// Builds the [Uri] to launch. For `mailto:` links the recipient is extracted
/// and a `subject` query is attached; returns `null` for empty or sanitized
/// (`#`) URLs so the caller can surface an error.
Uri? _resolveUri(String rawUrl, {required String supportSubject}) {
  final trimmed = rawUrl.trim();
  if (trimmed.isEmpty || trimmed == '#') return null;

  if (trimmed.toLowerCase().startsWith('mailto:')) {
    final recipient = _recipientFromMailto(trimmed);
    if (recipient.isEmpty) return null;
    return Uri(
      scheme: 'mailto',
      path: recipient,
      query: 'subject=${Uri.encodeComponent(supportSubject)}',
    );
  }

  return Uri.tryParse(trimmed);
}

/// Returns the bare recipient from a `mailto:` URL, dropping any existing
/// `?subject=…&body=…` query.
String _recipientFromMailto(String mailto) {
  var rest = mailto.substring('mailto:'.length);
  final queryStart = rest.indexOf('?');
  if (queryStart != -1) rest = rest.substring(0, queryStart);
  return rest.trim();
}
