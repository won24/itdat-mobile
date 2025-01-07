import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:itdat/widget/login_screen/login_screen.dart';
import 'package:itdat/screen/mainLayout.dart';
import 'package:itdat/widget/register/register_screen.dart';
import 'package:itdat/providers/theme_provider.dart';
import 'package:itdat/providers/auth_provider.dart';
import 'package:itdat/providers/locale_provider.dart';
import 'package:itdat/providers/font_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uni_links3/uni_links.dart';

import 'models/login_model.dart';
import 'models/social_model.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(
    nativeAppKey: '387812a6ae2897c3e9e59952c211374e',
    javaScriptAppKey: '159e7d3d7b574fff05fa693174bfa8a8',
    loggingEnabled: true, // 디버깅 로그 활성화
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => FontProvider()),
        ChangeNotifierProvider(create: (_) => LoginModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _handleIncomingLinks() {
    final socialsModel = SocialsModel();

    _sub = uriLinkStream.listen((Uri? uri) async {
      if (uri != null) {
        print("Received URI: $uri");

        // Kakao OAuth 리다이렉트 처리
        if (uri.scheme.startsWith('kakao') && uri.host == 'oauth') {
          final String? code = uri.queryParameters['code'];
          final String? error = uri.queryParameters['error'];

          if (code != null) {
            print("Kakao OAuth 성공, Authorization Code: $code");

            try {
              final result = await socialsModel.handleKakaoAuthCode(code);

              if (result['success']) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (result['data']['requiresRegistration']) {
                    navigatorKey.currentState?.pushNamed(
                      '/register',
                      arguments: {
                        'provider': 'KAKAO',
                        'providerId': result['data']['providerId'],
                        'email': result['data']['email'],
                      },
                    );
                  } else {
                    navigatorKey.currentState?.pushReplacementNamed(
                      '/main',
                      arguments: result['data']['token'],
                    );
                  }
                });
              } else {
                _showSnackBar(
                  'Kakao 처리 실패: ${result['message']}',
                );
              }
            } catch (e) {
              print("Kakao 처리 중 오류 발생: $e");
              _showSnackBar('Kakao 처리 중 오류 발생: $e');
            }
          } else if (error != null) {
            print("Kakao OAuth 실패: $error");
            _showSnackBar('Kakao 로그인 실패: $error');
          }
          return; // Kakao 처리 이후 추가 로직 중단
        }

        // 기존 Main 및 Register 처리
        final path = uri.host;
        final queryParams = uri.queryParameters;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (path == 'main') {
            final token = queryParams['token'] ?? '';
            print("Navigating to /main with token: $token");
            navigatorKey.currentState?.pushNamed('/main', arguments: token);
          } else if (path == 'register') {
            final providerId = queryParams['providerId'] ?? '';
            final email = queryParams['email'] ?? '';
            final providerType = queryParams['providerType'] ?? '';
            print("Navigating to /register with params: providerId=$providerId, email=$email, providerType=$providerType");
            navigatorKey.currentState?.pushNamed(
              '/register',
              arguments: {
                'providerId': providerId,
                'email': email,
                'providerType': providerType,
              },
            );
          } else {
            print("Unhandled path: $path");
          }
        });
      } else {
        print("No URI received");
      }
    }, onError: (err) {
      print('Error occurred while listening for deep links: $err');
    });
  }

  void _showSnackBar(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } else {
        print("SnackBar 표시 실패: context가 null입니다.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<LocaleProvider, ThemeProvider, AuthProvider, FontProvider>(
      builder: (context, localeProvider, themeProvider, authProvider, fontProvider, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'ITDAT',
          theme: themeProvider.lightTheme.copyWith(
            textTheme: fontProvider.currentTextTheme,
          ),
          darkTheme: themeProvider.darkTheme.copyWith(
            textTheme: fontProvider.currentTextTheme,
          ),
          themeMode: themeProvider.themeMode,
          locale: localeProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English
            Locale('ko', ''), // Korean
            Locale('ja', ''), // Japanese
          ],

          initialRoute: '/',
          routes: {
            '/': (context) => LoginScreen(),
            '/main': (context) => const MainLayout(),
            '/register': (context) {
              final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
              return RegisterScreen(
                registrationData: args?.map((key, value) => MapEntry(key, value.toString())),
              );
            },
          },
        );
      },
    );
  }
}
