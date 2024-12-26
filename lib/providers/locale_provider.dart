import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = Locale('ko');
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    String? savedLocale = await _storage.read(key: 'locale');
    if (savedLocale != null) {
      _locale = Locale(savedLocale);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _storage.write(key: 'locale', value: locale.languageCode);
    notifyListeners();
  }
}