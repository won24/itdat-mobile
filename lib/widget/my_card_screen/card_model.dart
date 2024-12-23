import 'package:dio/dio.dart';

class CardModel{

  final baseUrl = "http://localhost:8082";

  Future<List<dynamic>> searchUserInfo(int userCode) async{
    final dio = Dio();

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
}