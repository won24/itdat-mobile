import 'package:dio/dio.dart';
import 'package:itdat/models/BusinessCard.dart';

class CardModel{

  final baseUrl = "http://localhost:8082/card";
  final dio = Dio();

  // 유저 정보 가져오기
  Future<List<String>> getUserInfo(String userId) async{

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
    try{
      final response = await dio.get("$baseUrl/$userId");

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => BusinessCard.fromJson(item)).toList();
      } else {
        throw Exception('명함 가져오기 실패');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}