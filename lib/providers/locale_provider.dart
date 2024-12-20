import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = Locale('ko', '');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!['en', 'ko','ja'].contains(locale.languageCode)) return;
    _locale = locale;
    notifyListeners();
  }

  void clearLocale() {
    _locale = Locale('ko', '');
    notifyListeners();
  }
}