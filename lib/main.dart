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
import 'package:itdat/providers/font_provider.dart'; // FontProvider import 추가

void main() {
  KakaoSdk.init(nativeAppKey: '387812a6ae2897c3e9e59952c211374e');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => FontProvider()), // FontProvider 추가
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Consumer<FontProvider>( // FontProvider Consumer 추가
          builder: (context, fontProvider, child) {
            return MaterialApp(
              theme: ThemeData(
                appBarTheme: AppBarTheme(
                  foregroundColor: Colors.black,
                  elevation: 0,
                  centerTitle: false,
                  titleSpacing: 0,
                  titleTextStyle: fontProvider.currentTextTheme.titleLarge?.copyWith(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                textTheme: fontProvider.currentTextTheme,
              ),
              darkTheme: ThemeData.dark().copyWith(
                appBarTheme: AppBarTheme(
                  foregroundColor: Colors.white,
                  elevation: 0,
                  centerTitle: false,
                  titleSpacing: 0,
                  titleTextStyle: fontProvider.currentTextTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                textTheme: fontProvider.currentTextTheme,
              ),
              themeMode: themeProvider.themeMode,
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Provider.of<LocaleProvider>(context).locale,
              home: FutureBuilder<bool>(
                future: Provider.of<AuthProvider>(context, listen: false).checkLoginStatus(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else {
                    if (snapshot.data == true) {
                      return MainLayout();
                    } else {
                      return LoginScreen();
                    }
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}