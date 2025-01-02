import 'dart:convert';

import 'package:dio/dio.dart';

class NfcModel {
  final String baseUrl = "http://112.221.66.174:8000/nfc";
  final Dio _dio = Dio();

  NfcModel() {
    _dio.options.baseUrl = baseUrl;
  }

  Future<void> processCardInfo(Map<String, dynamic> cardInfo) async {
    try {
      final response = await _dio.post(
        '/save',
        data: jsonEncode(cardInfo),
        options: Options(headers: {"Content-Type": "application/json; charset=UTF-8"}),
      );

      if (response.statusCode == 200) {
        print('카드 정보가 성공적으로 처리되었습니다.');
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: '서버 응답 오류: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('Dio 오류: ${e.message}');
      throw Exception('서버 통신 중 오류 발생: ${e.message}');
    }
  }
}