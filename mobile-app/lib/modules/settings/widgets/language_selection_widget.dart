import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/extentions/context_extensions.dart';
import '../../../providers/locale_provider.dart';
import '../../../widgets/common_bottom_sheet.dart';

class LanguageSelectionWidget extends StatelessWidget {
  const LanguageSelectionWidget({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const LanguageSelectionWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final localeProvider = Provider.of<LocaleProvider>(context);

    final options = {'en': l10n.english, 'ar': l10n.arabic};

    Future<void> applyAndClose(String code) async {
      await localeProvider.setLocale(Locale(code));
      if (context.mounted) Navigator.of(context).pop();
    }

    return RadioGroup<String>(
      groupValue: localeProvider.locale.languageCode,
      onChanged: (value) {
        if (value != null) {
          applyAndClose(value);
        }
      },
      child: CommonBottomSheet(
        title: l10n.language,
        childrens: options.entries
            .mapIndexed(
              (index, element) => ListTile(
                onTap: () => applyAndClose(element.key),
                title: Text(element.value),
                trailing: Radio<String>(value: element.key),
              ),
            )
            .toList(),
      ),
    );
  }
}
