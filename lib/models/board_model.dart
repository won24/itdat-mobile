import 'dart:convert';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BoardModel{

  // static const String baseUrl = "http://112.221.66.174:8001/board/portfolio";
  // static const String historyBaseUrl = "http://112.221.66.174:8001/board/history";

  final baseUrl = "${dotenv.env['BASE_URL']}/board/portfolio";
  final historyBaseUrl = "${dotenv.env['BASE_URL']}/board/history";

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

  // 포트폴리오 가져오기
  Future<List<Map<String,dynamic>>> getPosts(String userEmail) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/$userEmail"));
      handleResponse(response, "getPosts");
      return List<Map<String, dynamic>>.from(jsonDecode(utf8.decode(response.bodyBytes)));
    } catch (e) {
      logError("getPosts", e);
      throw Exception("getPosts Error: $e");
    }
  }

  // 포트폴리오 저장
  Future<void> savePost(Map<String, dynamic> postData) async {
    try {
      final url = Uri.parse("$baseUrl/save");
      var request = http.MultipartRequest('POST', url);
      request.fields['postData'] = json.encode(postData).trim();

      if (postData['fileUrl'] != null && postData['fileUrl']!.isNotEmpty) {
        final file = File(postData['fileUrl']);
        final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
        final fileName = path.basename(file.path);

        request.files.add(
          http.MultipartFile(
            'file',
            file.readAsBytes().asStream(),
            file.lengthSync(),
            filename: fileName,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      final response = await request.send();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print("[savePost] 성공");
      } else {
        print("[savePost] 실패: ${response.statusCode}");
        throw Exception("savePost Error: ${response.statusCode}");
      }
    } catch (e) {
      print("[savePost] Error: $e");
      throw Exception("savePost Error: $e");
    }
  }



  // 포트폴리오 수정
  Future<void> editPost(Map<String, dynamic> postData, int postId) async {
    try {
      final url = Uri.parse("$baseUrl/edit/$postId");
      var request = http.MultipartRequest('PUT', url);
      request.fields['postData'] = json.encode(postData).trim();

      if (postData['fileUrl'] != null && postData['fileUrl']!.isNotEmpty) {
        final file = File(postData['fileUrl']);
        final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
        final fileName = path.basename(file.path);

        request.files.add(
          http.MultipartFile(
            'file',
            file.readAsBytes().asStream(),
            file.lengthSync(),
            filename: fileName,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      final response = await request.send();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print("[savePost] 성공");
      } else {
        print("[savePost] 실패: ${response.statusCode}");
        throw Exception("savePost Error: ${response.statusCode}");
      }
    } catch (e) {
      print("[savePost] Error: $e");
      throw Exception("savePost Error: $e");
    }
  }


  // 포트폴리오 삭제
  Future<void> deletePost(int postId) async {
    try{
      final response = await http.delete(Uri.parse("$baseUrl/delete/$postId"));
      handleResponse(response, "deletePost");
    } catch (e) {
      logError("deletePost", e);
      throw Exception("deletePost Error: $e");
    }
  }



  // 히스토리 가져오기
  Future<List<Map<String,dynamic>>> getHistories(String userEmail) async {
    try {
      final response = await http.get(Uri.parse("$historyBaseUrl/$userEmail"));
      handleResponse(response, "getHistories");
      return List<Map<String, dynamic>>.from(jsonDecode(utf8.decode(response.bodyBytes)));
    } catch (e) {
      logError("getHistories", e);
      throw Exception("getHistories Error: $e");
    }
  }


  // 히스토리 저장
  Future<void> saveHistory(Map<String, dynamic> postData) async {
    try {
      final response = await http.post(
        Uri.parse('$historyBaseUrl/save'),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: json.encode(postData).trim()
      );
      handleResponse(response, "saveHistoryPost");
    } catch (e) {
      logError("saveHistoryPost", e);
      throw Exception("saveHistoryPost Error: $e");
    }
  }

  // 히스토리 수정
  Future<void> editHistory(Map<String, dynamic> postData, int postId) async {
    try {
      final response = await http.put(
          Uri.parse("$historyBaseUrl/edit/$postId"),
          headers: {"Content-Type": "application/json; charset=UTF-8"},
          body: json.encode(postData).trim()
      );
      handleResponse(response, "editHistoryPost");
    } catch (e) {
      logError("editHistoryPost", e);
      throw Exception("editHistoryPost Error: $e");
    }
  }

  // 삭제
  Future<void> deleteHistory(int postId) async {
    try{
      final response = await http.delete(Uri.parse("$historyBaseUrl/delete/$postId"));
      handleResponse(response, "deleteHistory");
    } catch (e) {
      logError("deleteHistory", e);
      throw Exception("deleteHistory Error: $e");
    }
  }
}
