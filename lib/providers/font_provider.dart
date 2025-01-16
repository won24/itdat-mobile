import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FontProvider with ChangeNotifier {
  String _currentFont = 'Gowun Dodum';
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  
  String get currentFont => _currentFont;

  FontProvider() {
    _loadFont();
  }

  Future<void> _loadFont() async {
    try {
      String? storedFont = await _storage.read(key: 'font');
      if (storedFont != null) {
        _currentFont = storedFont;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading font: $e');
    }
  }

  Future<void> setFont(String font) async {
    try {
      await _storage.write(key: 'font', value: font);
      _currentFont = font;
      notifyListeners();
    } catch (e) {
      print('Error saving font: $e');
    }
  }

  TextTheme get currentTextTheme {
    if (_currentFont == 'System') {
      return ThemeData.light().textTheme; // 시스템 기본 폰트 사용
    }
    return GoogleFonts.getTextTheme(_currentFont);
  }

  // 언어별 폰트 리스트
  Map<String, List<String>> get fontsByLanguage => {
    'en': [
      'Gowun Dodum',
      'System',
      'Roboto',
      'Open Sans',
      'Lato',
      'Montserrat',
      'Lobster',
      'Oswald',
      'Pacifico',
      'Dancing Script',
      'Poppins',
    ],
    'ko': [
      'Gowun Dodum',
      'System',
      'Noto Sans KR',
      'Nanum Gothic',
      'Nanum Myeongjo',
      'Nanum Pen Script',
      'Gamja Flower',
      'Do Hyeon',
      'Gowun Batang',
      'Song Myung',
      'Stylish',
    ],
    'ja': [
      'Gowun Dodum',
      'System',
      'Noto Sans JP',
      'Kosugi',
      'Kosugi Maru',
      'Sawarabi Gothic',
      'Sawarabi Mincho',
      'M PLUS Rounded 1c',
      'M PLUS 1p',
      'Shippori Mincho',
    ],
  };


  List<String> getAvailableFontsForLocale(String localeCode) {
    return fontsByLanguage[localeCode] ?? fontsByLanguage['en']!;
  }
}