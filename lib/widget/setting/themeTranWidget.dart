import 'package:flutter/material.dart';
import 'package:itdat/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ThemeDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9, // 화면 너비의 90%
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.selectTheme,
                ),
                SizedBox(height: 9),
                //_buildThemeOption(context, ThemeMode.system, AppLocalizations.of(context)!.defaultTheme),
                _buildThemeOption(context, ThemeMode.light, AppLocalizations.of(context)!.light),
                _buildThemeOption(context, ThemeMode.dark, AppLocalizations.of(context)!.dark),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildThemeOption(BuildContext context, ThemeMode themeMode, String title) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return RadioListTile<ThemeMode>(
      title: Text(title),
      value: themeMode,
      groupValue: themeProvider.themeMode,
      onChanged: (ThemeMode? value) {
        if (value != null) {
          themeProvider.setThemeMode(value);
          Navigator.of(context).pop();
        }
      },
    );
  }
}