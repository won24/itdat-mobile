import 'dart:io';
import 'package:flutter/services.dart';


class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    SecurityContext newContext = SecurityContext.defaultContext;
    try {
      // 'assets/ca_bundle.crt' 파일을 rootBundle을 통해 읽어오기
      final certData = rootBundle.load('assets/ca_bundle.crt');
      certData.then((value) {
        final certBytes = value.buffer.asUint8List();
        newContext.setTrustedCertificatesBytes(certBytes);
      });
    } catch (e) {
      print("Failed to load certificate: $e");
    }
    return super.createHttpClient(newContext);
  }
}
