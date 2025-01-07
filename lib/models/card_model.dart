import 'dart:io';
import 'package:dio/dio.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';

class CardModel{

  //final baseUrl = "http://112.221.66.174:8001/card";  // 원
   final baseUrl = "http://112.221.66.174:8000/card"; //정원



  // 유저 정보 가져오기
  Future<Map<String, dynamic>> getUserById(String userEmail) async {

    try{
      final response = await http.get(Uri.parse("$baseUrl/userinfo/$userEmail"));

      if(response.statusCode == 200){
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data;
      } else {
        throw Exception('회원 정보 가져오기 실패: ${response.statusCode}');
      }
    }catch(e){
      print("회원 정보 가져오기 실패");
      throw Exception("getUserById Error: $e");
    }
  }



  // 명함 저장
  Future<BusinessCard> createBusinessCard(BusinessCard card) async {
    try{
        final response = await http.post(
          Uri.parse('$baseUrl/save'),
          headers: {"Content-Type": "application/json; charset=UTF-8" },
          body: json.encode(card.toJson()),
        );

        if(response.statusCode == 200){
          print("명함저장 성공");
          return BusinessCard.fromJson(json.decode(response.body));
        }else{
          throw Exception('명함 저장 실패: ${response.statusCode}');
        }
    }catch(e){
      print("명함 생성 실패 $e");
      throw Exception("createBusinessCard Error: $e");
    }
  }



  // 로고있는 명함 저장
  Future<void> saveBusinessCardWithLogo(BusinessCard cardInfo) async {
      final url = Uri.parse('$baseUrl/save/logo');

      var request = http.MultipartRequest('POST', url);
      request.fields['cardInfo'] = jsonEncode(cardInfo.toJson());

      if (cardInfo.logoPath != null && cardInfo.logoPath!.isNotEmpty) {
        File logoFile = File(cardInfo.logoPath!);
        String? mimeType = lookupMimeType(logoFile.path); // 파일의 MIME 타입 동적 확인
        String fileName = path.basename(logoFile.path); // 파일 이름 추출

        request.files.add(http.MultipartFile.fromBytes(
          'logo',
          await logoFile.readAsBytes(),
          contentType: mimeType != null ? DioMediaType.parse(mimeType) : DioMediaType('application', 'octet-stream'),
          filename: fileName,
        ));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        print("명함 저장 성공");
      } else {
        var responseBody = await response.stream.bytesToString();
        print("명함 저장 실패: ${response.statusCode} - $responseBody");
        throw Exception("명함 저장 실패");
      }
  }



  // 명함 가져오기
  Future<List<dynamic>> getBusinessCard(String userEmail) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/$userEmail"));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data;
      } else {
        throw Exception('명함 가져오기 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('getBusinessCard Error: $e');
    }
  }

}


