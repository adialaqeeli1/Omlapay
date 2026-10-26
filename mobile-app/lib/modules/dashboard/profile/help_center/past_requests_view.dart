import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/common_back_button.dart';
import 'widgets/filter_bottom_sheet.dart';

class PastRequestsView extends StatelessWidget {
  const PastRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: CommonBackButton(onPressed: () => GoRouter.of(context).pop()),
        title: Text(
          l10n.pastRequests,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/filter-icon.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                theme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              FilterBottomSheet.show(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Transform.translate(
          offset: Offset(0, -MediaQuery.of(context).size.height * 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                theme.brightness == Brightness.dark
                    ? 'assets/icons/empty-state-dark.svg'
                    : 'assets/icons/empty-state-light.svg',
                width: 250,
                height: 200,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Text(
                l10n.noRequestsFound,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.brightness == Brightness.dark
                      ? AppColors.textWhite
                      : AppColors.textBlack,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Text(
                l10n.allRequestsWillBeListedHere,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.brightness == Brightness.dark
                      ? AppColors.textLightGrey
                      : AppColors.textLightGrey,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
