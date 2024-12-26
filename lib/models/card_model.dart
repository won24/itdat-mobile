import 'package:dio/dio.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CardModel{

  final baseUrl = "http://112.221.66.174:8001/card";
  final dio = Dio();

  // 유저 정보 가져오기
  Future<List<String>> getUserInfo(String userId) async{
    final dio = Dio();

    try{
      final response = await dio.get("$baseUrl/userinfo/$userId");

      if(response.statusCode == 200){
        print("회원 정보: $response");
        return response.data as List<String>;
      }else{
        throw Exception("회원 정보 가져오기 실패");
      }
    }catch(e){
      print("회원 정보 가져오기 실패");
      throw Exception("Error: $e");
    }
  }

  // 템플릿 가져오기
  Future<List<Map<String, dynamic>>> getTemplates() async {
    try{
      final response = await dio.get("$baseUrl/templates");
      print("템플릿 : $response");
      return List<Map<String, dynamic>>.from(response.data);
    }catch(e){
      print("템플릿 가져오기 실패");
      throw Exception("Error: $e");
    }
  }

  // Svg content 로 변환
  Future<String> fetchSvgContent(String svgUrl) async {
    try {
      final response = await http.get(Uri.parse(svgUrl));  // URL로부터 SVG 데이터 가져오기

      if (response.statusCode == 200) {
        // 서버에서 SVG 파일을 성공적으로 가져옴
        return response.body;  // SVG 파일의 내용 (문자열 형태)
      } else {
        throw Exception('SVG 파일 로드 실패');
      }
    } catch (e) {
      throw Exception('Error fetching SVG: $e');
    }
  }


  // 명함 저장
  Future<Map<String,dynamic>> createBusinessCard(
      Map<String, dynamic> userInfo, String logoPath, int templateId, String userId) async {

    try{
      final formData = FormData.fromMap({
        'info': userInfo,
        'templateId': templateId,
        'logo': await MultipartFile.fromFile(logoPath, filename: 'logo.png'),
        'userId': userId
      });

      final response = await dio.post('$baseUrl/save', data: formData);

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('명함 생성 실패');
      }
    }catch(e){
      print("명함 생성 실패");
      throw Exception("Error: $e");
    }
  }


  // 명함 가져오기
  Future<List<BusinessCard>> getBusinessCard(String userId) async {
    try {
      print(userId);
      final response = await http.get(Uri.parse("$baseUrl/$userId"));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print(data);
        return data.map((item) => BusinessCard.fromJson(item)).toList();
      } else {
        throw Exception('명함 가져오기 실패');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}


