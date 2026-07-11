import 'package:flutter/material.dart';
import 'package:omlapay_mobile_app/core/extentions/string_extensions.dart';
import 'package:omlapay_mobile_app/widgets/common_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../../../core/extentions/context_extensions.dart';
import '../../../core/theme/theme.dart';
import '../../../providers/theme_provider.dart';

class AppearanceSelectionWidget extends StatelessWidget {
  const AppearanceSelectionWidget({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const AppearanceSelectionWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final themeProvider = Provider.of<ThemeProvider>(context);

    final Map<String, ThemeMode> options = {
      l10n.dark: ThemeMode.dark,
      l10n.light: ThemeMode.light,
      l10n.system: ThemeMode.system,
    };

    Future<void> applyAndClose(ThemeMode mode) async {
      await themeProvider.setThemeMode(mode);
      if (context.mounted) Navigator.of(context).pop();
    }

    return RadioGroup<ThemeMode>(
      groupValue: themeProvider.themeMode,
      onChanged: (value) {
        if (value != null) {
          applyAndClose(value);
        }
      },
      child: CommonBottomSheet(
        title: l10n.appearance,
        childrens: options.entries.map((e) {
          String description = switch (e.value) {
            ThemeMode.dark => l10n.darkMode,
            ThemeMode.light => l10n.lightMode,
            _ => l10n.usesDeviceSettings,
          };
          return ListTile(
            onTap: () => applyAndClose(e.value),
            title: Text(e.key.capitalizeFirst!),
            subtitle: Text(
              description,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: AppColors.textLightGrey),
            ),
            trailing: Radio<ThemeMode>(value: e.value),
          );
        }).toList(),
      ),
    );

    // return Container(
    //   decoration: BoxDecoration(
    //     color: backgroundColor,
    //     borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
    //   ),
    //   child: SafeArea(
    //     child: Column(
    //       mainAxisSize: MainAxisSize.min,
    //       children: [
    //         // Header
    //         Padding(
    //           padding: EdgeInsets.symmetric(
    //             horizontal: screenWidth * 0.05,
    //             vertical: 16,
    //           ),
    //           child: Stack(
    //             alignment: Alignment.center,
    //             children: [
    //               Text(
    //                 l10n.appearance,
    //                 textAlign: TextAlign.center,
    //                 style: TextStyle(
    //                   color: textColor,
    //                   fontSize: screenWidth * 0.045,
    //                   fontWeight: FontWeight.bold,
    //                 ),
    //               ),
    //               Align(
    //                 alignment: Alignment.centerRight,
    //                 child: IconButton(
    //                   icon: Icon(Icons.close, color: textColor, size: 30),
    //                   onPressed: () => Navigator.of(context).pop(),
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),

    //         // Options
    //         _buildOption(
    //           context: context,
    //           title: l10n.dark,
    //           subtitle: l10n.darkMode,
    //           themeMode: ThemeMode.dark,
    //           currentThemeMode: themeProvider.themeMode,
    //           screenWidth: screenWidth,
    //           textColor: textColor,
    //           dividerColor: dividerColor,
    //         ),
    //         Padding(
    //           padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
    //           child: const Divider(height: 1, thickness: 1),
    //         ),
    //         _buildOption(
    //           context: context,
    //           title: l10n.light,
    //           subtitle: l10n.lightMode,
    //           themeMode: ThemeMode.light,
    //           currentThemeMode: themeProvider.themeMode,
    //           screenWidth: screenWidth,
    //           textColor: textColor,
    //           dividerColor: dividerColor,
    //         ),
    //         Padding(
    //           padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
    //           child: const Divider(height: 1, thickness: 1),
    //         ),
    //         _buildOption(
    //           context: context,
    //           title: l10n.system,
    //           subtitle: l10n.usesDeviceSettings,
    //           themeMode: ThemeMode.system,
    //           currentThemeMode: themeProvider.themeMode,
    //           screenWidth: screenWidth,
    //           textColor: textColor,
    //           dividerColor: dividerColor,
    //         ),

    //         SizedBox(height: MediaQuery.of(context).padding.bottom),
    //       ],
    //     ),
    //   ),
    // );
  }

  // Widget _buildOption({
  //   required BuildContext context,
  //   required String title,
  //   required String subtitle,
  //   required ThemeMode themeMode,
  //   required ThemeMode currentThemeMode,
  //   required double screenWidth,
  //   required Color textColor,
  //   required Color dividerColor,
  // }) {
  //   final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

  //   return InkWell(
  //     onTap: () async {
  //       await themeProvider.setThemeMode(themeMode);
  //       if (context.mounted) {
  //         Navigator.of(context).pop();
  //       }
  //     },
  //     child: Padding(
  //       padding: EdgeInsets.symmetric(
  //         horizontal: screenWidth * 0.05,
  //         vertical: 16,
  //       ),
  //       child: Row(
  //         children: [
  //           Expanded(
  //             child: Padding(
  //               padding: EdgeInsets.only(left: screenWidth * 0.03),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     title,
  //                     style: TextStyle(
  //                       color: textColor,
  //                       fontSize: screenWidth * 0.042,
  //                       fontWeight: FontWeight.w500,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 4),
  //                   Text(
  //                     subtitle,
  //                     style: TextStyle(
  //                       color: textColor.withOpacity(0.6),
  //                       fontSize: screenWidth * 0.036,
  //                       fontWeight: FontWeight.w400,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           Transform.scale(
  //             scale: 1.3,
  //             child: Radio<ThemeMode>(
  //               value: themeMode,
  //               groupValue: currentThemeMode,
  //               onChanged: (value) async {
  //                 if (value != null) {
  //                   await themeProvider.setThemeMode(value);
  //                   if (context.mounted) {
  //                     Navigator.of(context).pop();
  //                   }
  //                 }
  //               },
  //               activeColor: AppColors.primaryColor,
  //               fillColor: WidgetStateProperty.resolveWith<Color>((states) {
  //                 if (states.contains(WidgetState.selected)) {
  //                   return AppColors.primaryColor;
  //                 }
  //                 return textColor.withOpacity(0.3);
  //               }),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
