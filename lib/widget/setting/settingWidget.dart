import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:itdat/widget/setting/languageTranWidget.dart';
import 'package:itdat/widget/setting/themeTranWidget.dart';

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
        title: Text(AppLocalizations.of(context)!.setting),
      ),
      body: ListView(
        children: [
          _buildSettingItem(Icons.language_outlined, AppLocalizations.of(context)!.language, () {
            LanguageDialog.show(context);
          }),
          _buildSettingItem(Icons.palette_outlined, AppLocalizations.of(context)!.theme, () {
            ThemeDialog.show(context);
          }),
          _buildSettingItem(Icons.lock_outline_rounded, AppLocalizations.of(context)!.security, () {
            //보안
          }),
          _buildSettingItem(Icons.info_outline, AppLocalizations.of(context)!.about, () {
            // 앱 정보 페이지로 이동
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
            Icon(icon, size: 24),
            SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(fontSize: 18),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}