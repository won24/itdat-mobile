import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'login_screen.dart';
import 'login_service.dart';

class LogoutWidget {
  static Future<void> show(BuildContext context) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.logout),
          content: Text("로그아웃 동의"),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.confirm),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final AuthService authService = AuthService();
      final bool success = await authService.logout();
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.logoutSuccessful)),
        );
        // 로그인 화면으로 이동
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.logoutError)),
        );
      }
    }
  }
}