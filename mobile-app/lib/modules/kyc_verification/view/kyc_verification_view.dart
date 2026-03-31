import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/extentions/context_extensions.dart';
import '../utils/kyc_verification_entry_source.dart';
import '../../../widgets/common_back_button.dart';

class KycVerificationView extends StatefulWidget {
  const KycVerificationView({
    super.key,
    this.entrySource = KycVerificationEntrySource.unknown,
  });

  final KycVerificationEntrySource entrySource;

  @override
  State<KycVerificationView> createState() => _KycVerificationViewState();
}

class _KycVerificationViewState extends State<KycVerificationView> {
  static const String _baseUrl = 'https://www.wikipedia.org/';
  late final WebViewController _controller;

  String get _url {
    final sourceValue = switch (widget.entrySource) {
      KycVerificationEntrySource.profile => 'profile',
      KycVerificationEntrySource.send => 'send',
      KycVerificationEntrySource.receive => 'receive',
      KycVerificationEntrySource.swap => 'swap',
      KycVerificationEntrySource.receiveHistory => 'receive_history',
      KycVerificationEntrySource.unknown => 'unknown',
    };
    return '$_baseUrl?source=$sourceValue';
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(_url));

    log('url: $_url for page ${widget.entrySource}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const CommonBackButton(),
        title: Text(
          l10n.kycVerification,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
