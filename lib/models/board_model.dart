import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class BoardModel{

  // static const String baseUrl = "http://112.221.66.174:8001/board"; // 원
  final String baseUrl = 'http://112.221.66.174:8002/board'; // seo

  void logError(String functionName, dynamic error) {
    print("[$functionName] Error: $error");
  }

  void handleResponse(http.Response response, String functionName) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      print("[$functionName] 성공");
    } else {
      print("[$functionName] 실패: ${response.statusCode}");
      throw Exception("[$functionName] Error: ${response.statusCode}");
    }
  }

  // 가져오기
  Future<List<Map<String,dynamic>>> getPosts(String userEmail) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/userinfo/$userEmail"));
      handleResponse(response, "getPosts");
      return List<Map<String, dynamic>>.from(jsonDecode(utf8.decode(response.bodyBytes)));
    } catch (e) {
      logError("getPosts", e);
      throw Exception("getPosts Error: $e");
    }
  }

  // 저장
  Future<void> savePost(Map<String, dynamic> postData) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/save"),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: json.encode(postData),
      );
      handleResponse(response, "savePost");
    } catch (e) {
      logError("savePost", e);
      throw Exception("savePost Error: $e");
    }
  }



  // 수정
  Future<void> editPost(Map<String, dynamic> postData, int postId) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/edit/$postId"),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: json.encode(postData),
      );
      handleResponse(response, "editPost");
    } catch (e) {
      logError("editPost", e);
      throw Exception("editPost Error: $e");
    }
  }


  // 삭제
  Future<void> deletePost(int postId) async {
    try{
      final response = await http.delete(Uri.parse("$baseUrl/delete/$postId"));
      handleResponse(response, "deletePost");
    } catch (e) {
      logError("deletePost", e);
      throw Exception("deletePost Error: $e");
    }
  }
}
