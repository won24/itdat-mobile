import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

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
          _buildSettingItem(Icons.language, AppLocalizations.of(context)!.language, () {
            // 언어 설정 페이지로 이동
          }),
          _buildSettingItem(Icons.palette, AppLocalizations.of(context)!.theme, () {
            // 테마 설정 페이지로 이동
          }),
          _buildSettingItem(Icons.info, AppLocalizations.of(context)!.about, () {
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
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(icon, size: 24),
            SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(fontSize: 16),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}