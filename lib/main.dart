import 'package:flutter/material.dart';
import 'package:itdat/providers/theme_provider.dart';
import 'package:itdat/providers/auth_provider.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';
import 'package:itdat/screen/mainLayout.dart';
import 'package:itdat/widget/login_screen/login_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:itdat/providers/locale_provider.dart';
import 'package:itdat/providers/font_provider.dart';

void main() {
  KakaoSdk.init(nativeAppKey: '387812a6ae2897c3e9e59952c211374e');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => FontProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer4<LocaleProvider, ThemeProvider, AuthProvider, FontProvider>(
      builder: (context, localeProvider, themeProvider, authProvider, fontProvider, child) {
        return MaterialApp(
          title: 'ITDAT',
          theme: themeProvider.lightTheme.copyWith(
            textTheme: fontProvider.currentTextTheme,
          ),
          darkTheme: themeProvider.darkTheme.copyWith(
            textTheme: fontProvider.currentTextTheme,
          ),
          themeMode: themeProvider.themeMode,
          locale: localeProvider.locale,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('en', ''), // English
            Locale('ko', ''), // Korean
            Locale('ja', ''), // Japanese
          ],
          home: FutureBuilder(
            future: authProvider.checkLoginStatus(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else {
                return authProvider.isLoggedIn ? MainLayout() : MainLayout();
              }
            },
          ),
        );
      },
    );
  }
}