import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:itdat/providers/locale_provider.dart';

class LanguageDialog {
  static void show(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    Locale selectedLocale = localeProvider.locale;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.language,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white : Colors.black,
                         ),
                    ),
                    SizedBox(height: 16),
                    _buildLanguageOption(context, Locale('en'), 'English', selectedLocale, (value) {
                      setState(() => selectedLocale = value!);
                    }),
                    _buildLanguageOption(context, Locale('ko'), '한국어', selectedLocale, (value) {
                      setState(() => selectedLocale = value!);
                    }),
                    _buildLanguageOption(context, Locale('ja'), '日本語', selectedLocale, (value) {
                      setState(() => selectedLocale = value!);
                    }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          child: Text(AppLocalizations.of(context)!.cancel),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        ),
                        TextButton(
                          child: Text(AppLocalizations.of(context)!.confirm),
                          onPressed: () {
                            localeProvider.setLocale(selectedLocale);
                            Navigator.of(dialogContext).pop();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildLanguageOption(BuildContext context, Locale locale, String title, Locale groupValue, ValueChanged<Locale?> onChanged) {
    return RadioListTile<Locale>(
      title: Text(title),
      value: locale,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: Theme.of(context).primaryColor,
    );
  }
}