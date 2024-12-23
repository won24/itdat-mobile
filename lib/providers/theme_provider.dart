import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode themeMode) {
    _themeMode = themeMode;
    notifyListeners();
  }

  // 라이트 테마 정의
  ThemeData get lightTheme => ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    // 여기에 라이트 테마에 대한 추가 설정을 넣을 수 있습니다.
  );

  // 다크 테마 정의
  ThemeData get darkTheme => ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
    // 여기에 다크 테마에 대한 추가 설정을 넣을 수 있습니다.
  );

}