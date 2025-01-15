import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:itdat/models/http_client_model.dart';
import 'BusinessCard.dart';

class PublicCardModel {
  final baseUrl = dotenv.env['BASE_URL'];
  // final String baseUrl = "http://10.0.2.2:8082/card/public";
  //  final String baseUrl = "http://112.221.66.174:8001/card/public";

  //final String baseUrl = "http://10.0.2.2:8082/card/public";
  // final String baseUrl = "http://112.221.66.174:8001/card/public";
  // final String baseUrl = "http://112.221.66.174:8002/card/public"; // seo
  // final String baseUrl = "http://112.221.66.174:8000/card/public";

  // 전체 공개 명함 가져오기
  Future<List<dynamic>> getAllPublicCards() async {
    final client = await HttpClientModel().createHttpClient();

    try {
      final response = await client.get(Uri.parse("$baseUrl/card/public/all"));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        print("응답 실패: ${response.statusCode}");
        throw Exception('Failed to fetch public business cards');
      }
    } catch (e) {
      print("오류 발생: ${e.toString()}");
      throw Exception('Error fetching public business cards: $e');
    }
  }



  // 명함 공개 설정 변경
  Future<void> updateCardVisibility({
    required String userEmail,
    required bool isPublic,
  }) async {
    final client = await HttpClientModel().createHttpClient();

    try {
      final response = await client.post(
        Uri.parse("$baseUrl/card/public/update"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userEmail": userEmail,
          "isPublic": isPublic,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update card visibility');
      }
    } catch (e) {
      throw Exception('Error updating card visibility: $e');
    }
  }
}
