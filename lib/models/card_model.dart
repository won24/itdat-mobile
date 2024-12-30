import 'package:dio/dio.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CardModel{

  final baseUrl = "http://112.221.66.174:8001/card";  // 원
  final dio = Dio();


  // 유저 정보 가져오기
  Future<dynamic> getUserById(String userId) async {

    try{
      final response = await http.get(Uri.parse("$baseUrl/userinfo/$userId"));

      if(response.statusCode == 200){
        final Map<String, dynamic> data = json.decode(response.body);
        print("유저정보: $data");
      } else {
        throw Exception('회원 정보 가져오기 실패');
      }
    }catch(e){
      print("회원 정보 가져오기 실패");
      throw Exception("getUserById Error: $e");
    }
  }



  // 명함 저장
  Future<BusinessCard> createBusinessCard(String userId, BusinessCard card) async {
    try{
        final response = await http.post(
          Uri.parse('$baseUrl/save/$userId'),
          headers: {"Content-Type": "application/json"},
          body: json.encode(card.toJson()),
        );

        if(response.statusCode == 200){
          return BusinessCard.fromJson(json.decode(response.body));
        }else{
          throw Exception('명함 생성 실패');
        }
    }catch(e){
      print("명함 생성 실패");
      throw Exception("createBusinessCard Error: $e");
    }
  }


  // 명함 가져오기
  Future<dynamic> getBusinessCard(String userId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/$userId"));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print(data);
      } else {
        throw Exception('명함 가져오기 실패');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}


