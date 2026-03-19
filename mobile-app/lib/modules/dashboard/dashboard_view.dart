import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:omlapay_mobile_app/core/theme/theme.dart';
import 'package:provider/provider.dart';

import '../../core/extentions/context_extensions.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_router.dart';

part './widget/bottom_navbar.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: child, bottomNavigationBar: _BottomNavbar());
  }
}
