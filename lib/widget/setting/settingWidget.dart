import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:itdat/widget/login_screen/logoutWidget.dart';
import 'package:itdat/widget/nfc/nfcWrite.dart';
import 'package:itdat/widget/setting/languageTranWidget.dart';
import 'package:itdat/widget/setting/permissionWidget.dart';
import 'package:itdat/widget/setting/themeTranWidget.dart';

import 'fontSelectWidget.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.setting,
      ),
      ),
      body: ListView(
        children: [
          _buildSettingItem(Icons.language_outlined, AppLocalizations.of(context)!.language, () {
            LanguageDialog.show(context);
          }),
          _buildSettingItem(Icons.palette_outlined, AppLocalizations.of(context)!.theme, () {
            ThemeDialog.show(context);
          }),
          _buildSettingItem(Icons.palette_outlined, AppLocalizations.of(context)!.font, () {
            FontDialog.show(context);
          }),

          _buildSettingItem(Icons.lock_outline_rounded, AppLocalizations.of(context)!.security, () {
            PermissionManager.navigateToPermissionSettings(context);
          }),
          _buildSettingItem(Icons.nfc_rounded, AppLocalizations.of(context)!.nfc, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NfcWritePage()),
            );
          }),
          _buildSettingItem(Icons.logout, AppLocalizations.of(context)!.logout, () {
            LogoutWidget.show(context);
          }),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Theme.of(context).iconTheme.color),
            SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}