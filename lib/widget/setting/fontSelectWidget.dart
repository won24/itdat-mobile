import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:itdat/providers/font_provider.dart';
import 'package:itdat/providers/locale_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class FontDialog {
  static void show(BuildContext context) {
    final fontProvider = Provider.of<FontProvider>(context, listen: false);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    String selectedFont = fontProvider.currentFont;
    String currentLocale = localeProvider.locale.languageCode;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            List<String> availableFonts = fontProvider.getAvailableFontsForLocale(currentLocale);

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8, // 화면 높이의 80%로 제한
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.font,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: availableFonts.map((fontName) =>
                            _buildFontOption(context, fontName, selectedFont, (value) {
                              setState(() => selectedFont = value!);
                            })
                        ).toList(),
                      ),
                    ),
                    SizedBox(height: 16),
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
                            fontProvider.setFont(selectedFont);
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

  static Widget _buildFontOption(BuildContext context, String fontName, String groupValue, ValueChanged<String?> onChanged) {
    return RadioListTile<String>(
      title: Text(fontName, style: _getFontStyle(fontName)),
      value: fontName,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: Theme.of(context).primaryColor,
    );
  }

  static TextStyle _getFontStyle(String fontName) {
    if (fontName == 'System') {
      return TextStyle(); // 시스템 기본 폰트
    }
    return GoogleFonts.getFont(fontName);
  }
}