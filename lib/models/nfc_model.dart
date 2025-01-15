import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NfcModel {
  
  // final String baseUrl = "http://112.221.66.174:8000";
  // final String baseUrl = "http://112.221.66.174:8002"; // seo
  final String baseUrl = "http://112.221.66.174:8001";
  // final String baseUrl = "http://112.221.66.174:8000"; // seo
  
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> processCardInfo(Map<String, dynamic> cardInfo) async {
    try {
      String? userEmail = await _storage.read(key: 'user_email');
      if (userEmail == null) {
        throw Exception('사용자 이메일을 찾을 수 없습니다.');
      }
      cardInfo['myEmail'] = userEmail;

      final response = await http.post(
        Uri.parse('$baseUrl/nfc/save'),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode(cardInfo),
      );

      if (response.statusCode == 200) {
        print('카드 정보가 성공적으로 처리되었습니다.');
      } else {
        throw Exception('서버 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('오류: ${e.toString()}');
      throw Exception('서버 통신 중 오류 발생: ${e.toString()}');
    }
  }

  Future<void> saveMemo(Map<String, dynamic> card) async {
    try {
      final response = await http.post(
          Uri.parse("$baseUrl/nfc/mywallet/cardmemo"),
          headers: {"Content-Type": "application/json; charset=UTF-8"},
          body: json.encode(card).trim()
      );
      handleResponse(response, "saveMemo");
    } catch (e) {
      logError("saveMemo", e);
      throw Exception("saveMemo Error: $e");
    }
  }

  Future<String?> loadMemo(Map<String, dynamic> card) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/nfc/mywallet/loadmemo"),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: json.encode(card),
      );

      if (response.statusCode == 200) {
        // 서버에서 직접 문자열을 반환한다고 가정
        return response.body;
      } else {
        print("메모 로드 실패: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("loadMemo Error: $e");
      throw Exception("loadMemo Error: $e");
    }
  }

  void handleResponse(http.Response response, String functionName) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      print("[$functionName] 성공");
    } else {
      var errorBody = utf8.decode(response.bodyBytes);
      print("[$functionName] 실패: ${response.statusCode} - $errorBody");
      throw Exception("[$functionName] Error: ${response.statusCode}");
    }
  }
  void logError(String functionName, dynamic error) {
    print("[$functionName] Error: $error");
  }

}