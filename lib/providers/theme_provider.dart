import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  //ThemeMode _themeMode = ThemeMode.system;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    String? savedThemeMode = await _storage.read(key: 'theme_mode');
    if (savedThemeMode != null) {
      _themeMode = ThemeMode.values.firstWhere(
            (e) => e.toString() == savedThemeMode,
        orElse: () => ThemeMode.system,
      );
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    await _storage.write(key: 'theme_mode', value: themeMode.toString());
    notifyListeners();
  }

  // 라이트 테마 정의
  ThemeData get lightTheme => ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    hintColor: Color.fromRGBO(0, 202, 145, 1),
    scaffoldBackgroundColor: Colors.white,
    canvasColor: Colors.white,
    cardColor: Colors.white,
    dividerColor: Colors.grey[300],
    appBarTheme: AppBarTheme(
      backgroundColor:Colors.white
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,

    // 여기에 라이트 테마에 대한 추가 설정을 넣을 수 있습니다.
  );

  // 다크 테마 정의
  ThemeData get darkTheme => ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
    // 여기에 다크 테마에 대한 추가 설정을 넣을 수 있습니다.
  );

}