import 'package:dio/dio.dart';

class CardModel{

  final baseUrl = "http://localhost:8082/card";
  final dio = Dio();

  // 유저 정보 가져오기
  Future<List<dynamic>> searchUserInfo(int userCode) async{

    try{
      final response = await dio.get("$baseUrl/userinfo/$userCode");

      if(response.statusCode == 200){
        print("회원 정보: $response");
        return response.data as List<dynamic>;
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
  Future<List<Map<String,dynamic>>> createBusinessCard(
      Map<String, dynamic> userInfo, String logoPath, int templateId) async {

    try{
      final formData = FormData.fromMap({
        'info': userInfo,
        'templateId': templateId,
        'logo': await MultipartFile.fromFile(logoPath, filename: 'logo.png'),
      });

      final response = await dio.post('$baseUrl/save', data: formData);
      return BusinessCard.fromJson(response.data);
    }catch(e){
      print("명함 저장 실패");
      throw Exception("Error: $e");
    }
  }


  // 명함 가져오기
  Future<BusinessCard> getBusinessCard(int userId) async {
    try{
      final response = await dio.get("$baseUrl/$userId");
      return BusinessCard.fromJson(response.data);
    }catch(e){
      print("명함 가져오기 실패");
      throw Exception("Error: $e");
    }
  }
}