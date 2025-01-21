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

    popupMenuTheme: PopupMenuThemeData(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      textStyle: TextStyle(
        color: Colors.black,
        fontSize: 16.0,
        fontWeight: FontWeight.w600
      ),
      elevation: 4.0,
    ),

  );

  // 다크 테마 정의
  ThemeData get darkTheme => ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
    hintColor: Color.fromRGBO(0, 202, 145, 1),
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      titleTextStyle: TextStyle(
        color: Colors.white, // AppBar 제목 색상
        fontSize: 20.0,
      ),
      iconTheme: IconThemeData(color: Colors.white), // AppBar 아이콘 색상
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,

    popupMenuTheme: PopupMenuThemeData(
      color: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color: Colors.white,
          width: 1.0,
        ),
      ),
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 16.0,
      ),
      elevation: 6.0,
    ),


  );

}