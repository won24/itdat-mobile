import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class BoardModel{

  static const String baseUrl = "http://112.221.66.174:8001/board"; // 원

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
  Future<void> savePost(Map<String, dynamic> postData, {required List<File> newFiles}) async {
    try{
      // 파일
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/save"),
      );

      // 텍스트 데이터 추가
      postData.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      // 파일 데이터 추가
      for (var file in newFiles) {
        final fileName = file.path.split('/').last;
        request.files.add(
          await http.MultipartFile.fromPath(
            'files', // 서버에서 기대하는 파일 키
            file.path,
            filename: fileName,
          ),
        );
      }

      final response = await request.send();
      if (response.statusCode == 200) {
        print("포트폴리오 저장 성공");
      } else {
        throw Exception("포트폴리오 저장 실패. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      logError("savePost", e);
      throw Exception("savePost Error: $e");
    }
  }


  // 수정
  Future<void> editPost(
      Map<String, dynamic> postData,
      int postId,
      {required List<File> newFiles}) async {

    try {
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse("$baseUrl/edit/$postId"),
      );

      postData.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      for (var file in newFiles) {
        final fileName = file.path.split('/').last;
        request.files.add(
          await http.MultipartFile.fromPath(
            'files', // 서버에서 기대하는 파일 키
            file.path,
            filename: fileName,
          ),
        );
      }

      final response = await request.send();
      if (response.statusCode == 200) {
        print("게시글 수정 성공");
      } else {
        throw Exception("게시글 수정 실패. Status Code: ${response.statusCode}");
      }
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
