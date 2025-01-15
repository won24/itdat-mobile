import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';

class HttpClientManager {
  IOClient? _httpClient;

  Future<IOClient> createHttpClient() async {
    if (_httpClient != null) return _httpClient!; // 이미 HttpClient 객체가 생성된 경우 재사용

    // 인증서 파일 로드
    final ByteData data = await rootBundle.load('assets/ca_bundle.crt');
    final List<int> bytes = data.buffer.asUint8List();

    // 인증서 파일을 SecurityContext에 추가
    final SecurityContext context = SecurityContext(withTrustedRoots: false);
    context.setTrustedCertificatesBytes(bytes);

    // dart:io HttpClient 생성 및 인증서 적용
    final HttpClient httpClient = HttpClient(context: context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    // IOClient 생성
    _httpClient = IOClient(httpClient);

    return _httpClient!;
  }
}
