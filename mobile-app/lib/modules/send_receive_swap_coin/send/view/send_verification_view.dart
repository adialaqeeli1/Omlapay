import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/theme.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../widgets/common_back_button.dart';
import '../../../../widgets/common_button.dart';

class SendVerificationView extends StatefulWidget {
  const SendVerificationView({super.key});

  @override
  State<SendVerificationView> createState() => _SendVerificationViewState();
}

class _SendVerificationViewState extends State<SendVerificationView> {
  // Mock OTP controller
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Verify Account',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const CommonBackButton(),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Text(
              'Enter the code sent to +966 50 *** **67',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 30),

            // Mock OTP Fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                6,
                (index) => Container(
                  width: 45,
                  height: 55,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2E2C),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.tealColor.withValues(alpha: 0.3),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _controllers[index],
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(border: InputBorder.none),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        FocusScope.of(context).nextFocus();
                      }
                      if (value.isEmpty && index > 0) {
                        FocusScope.of(context).previousFocus();
                      }
                    },
                  ),
                ),
              ),
            ),

            const Spacer(),

            CommonButton(
              title: 'Verify',
              onPressed: () async {
                // Mock verification success — update auth so send/swap gates refresh.
                await context.read<AuthProvider>().verifyUser();
                if (!context.mounted) return;
                context.pop(true);
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
