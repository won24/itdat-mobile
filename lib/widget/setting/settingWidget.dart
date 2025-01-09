import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:itdat/widget/card/cart_select_widget.dart';
import 'package:itdat/widget/card/openCardList.dart';
import 'package:itdat/widget/login_screen/logoutWidget.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // 전체 Column 왼쪽 정렬
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            AppLocalizations.of(context)!.setting,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 내부 항목도 왼쪽 정렬
          children: [
            _buildSettingItem(Icons.language_outlined, AppLocalizations.of(context)!.language, () {
              LanguageDialog.show(context);
            }),
            _buildSettingItem(Icons.palette_outlined, AppLocalizations.of(context)!.theme, () {
              ThemeDialog.show(context);
            }),
            _buildSettingItem(Icons.font_download_outlined, AppLocalizations.of(context)!.font, () {
              FontDialog.show(context);
            }),
            _buildSettingItem(Icons.lock_outline_rounded, AppLocalizations.of(context)!.security, () {
              PermissionManager.navigateToPermissionSettings(context);
            }),
            _buildSettingItem(Icons.nfc_rounded, AppLocalizations.of(context)!.nfc, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CardSelect(source: 'nfc')),
              );
            }),
            _buildSettingItem(Icons.people_alt_sharp, AppLocalizations.of(context)!.openCard, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OpenBusinessCardList()),
              );
            }),
            _buildSettingItem(Icons.logout, AppLocalizations.of(context)!.logout, () {
              LogoutWidget.show(context);
            }),
            _buildSettingItem(Icons.logout, AppLocalizations.of(context)!.logout, () {
              LogoutWidget.show(context);
            }),
            _buildSettingItem(Icons.logout, AppLocalizations.of(context)!.logout, () {
              LogoutWidget.show(context);
            }),
            _buildSettingItem(Icons.logout, AppLocalizations.of(context)!.logout, () {
              LogoutWidget.show(context);
            }),
            _buildSettingItem(Icons.logout, AppLocalizations.of(context)!.logout, () {
              LogoutWidget.show(context);
            }),
            _buildSettingItem(Icons.logout, AppLocalizations.of(context)!.logout, () {
              LogoutWidget.show(context);
            }),


          ],
        ),
      ],
    );
  }

  Widget _buildSettingItem(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // 아이콘과 텍스트의 수직 중앙 정렬
          children: [
            Icon(
              icon,
              size: 24,
              color: Theme.of(context).iconTheme.color,
            ),
            SizedBox(width: 15), // 아이콘과 텍스트 간격
            Expanded( // 텍스트가 왼쪽 정렬되도록 확장
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
