import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class MyWalletModel {
  // final String baseUrl = "http://10.0.2.2:8082/api/mywallet";
  // final String baseUrl2 = "http://10.0.2.2:8082/api/auth";

  final String baseUrl = "http://112.221.66.174:8001/api/mywallet";
  final String baseUrl2 = "http://112.221.66.174:8001/api/auth";



  // 명함 가져오기
  Future<List<dynamic>> getCards(String myEmail) async {
    final url = '$baseUrl/cards?myEmail=$myEmail';
    // print('API 요청: $url');
    try {
      final response = await http.get(Uri.parse(url));
      // print('API 응답 상태 코드: ${response.statusCode}');
      // print('API 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch cards');
      }
    } catch (e) {
      print('API 호출 중 오류: $e');
      rethrow;
    }
  }

  // 폴더 가져오기
  Future<List<dynamic>> getFolders(String userEmail) async {
    final url = '$baseUrl/folders?userEmail=$userEmail';
    // print('폴더 API 요청: $url');
    try {
      final response = await http.get(Uri.parse(url));
      // print('폴더 API 응답 상태 코드: ${response.statusCode}');
      // print('폴더 API 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch folders');
      }
    } catch (e) {
      print('폴더 API 호출 중 오류: $e');
      rethrow;
    }
  }

  // 폴더 내부 명함 가져오기
  Future<List<dynamic>> getFolderCards(String folderName) async {
    final url = '$baseUrl/folderCards?folderName=$folderName';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch folder cards');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 폴더 생성
  Future<bool> createFolder(String userEmail, String folderName) async {
    final response = await http.post(
      Uri.parse("$baseUrl/folders/create"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userEmail": userEmail, "folderName": folderName}),
    );
    return response.statusCode == 200;
  }

  // 폴더 이름 업데이트
  Future<bool> updateFolderName(String userEmail, String oldFolderName, String newFolderName) async {
    final response = await http.put(
      Uri.parse("$baseUrl/folders/update"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userEmail": userEmail,
        "oldFolderName": oldFolderName,
        "newFolderName": newFolderName
      }),
    );

    if (response.statusCode == 200) {
      print("폴더 이름 업데이트 성공");
      return true;
    } else {
      print("폴더 이름 업데이트 실패: ${response.statusCode}");
      return false;
    }
  }

  // 폴더 삭제
  Future<bool> deleteFolder(String userEmail, String folderName) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/folders/$folderName?userEmail=$userEmail"),
    );
    return response.statusCode == 200;
  }

  // 명함 폴더로 이동
  Future<bool> moveCardToFolder(String myEmail, String userEmail, String folderName) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/moveCard"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "myEmail": myEmail,
          "userEmail": userEmail,
          "folderName": folderName.isEmpty ? null : folderName, // 폴더 이름 처리
        }),
      );

      // debugPrint("응답 상태 코드: ${response.statusCode}");
      // debugPrint("응답 본문: ${response.body}");

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint("API 호출 실패: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("API 호출 중 오류: $e");
      return false;
    }
  }

  Future<Map<String, String>> getUserInfoByEmail(String email) async {
    final response = await http.get(
      Uri.parse('$baseUrl2/info?email=$email'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch user info');
    }
  }

  Future<List<dynamic>> getAllCards(String userEmail) async {
    final url = '$baseUrl/allCards?userEmail=$userEmail';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch business cards");
    }
  }

  // 폴더에 속하지 않은 명함 가져오기
  Future<List<dynamic>> getCardsWithoutFolder(String myEmail) async {
    final response = await http.get(
      Uri.parse("$baseUrl/cards/withoutFolder?myEmail=$myEmail"),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load cards without folder");
    }
  }

  // 특정 폴더의 명함 가져오기
  Future<List<dynamic>> getCardsByFolder(String myEmail, String folderName) async {
    final response = await http.get(
      Uri.parse("$baseUrl/cards/byFolder?myEmail=$myEmail&folderName=$folderName"),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load cards by folder");
    }
  }
}
