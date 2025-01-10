import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';

class CardModel{
   final storage = FlutterSecureStorage();
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
        print('명함 가져오기$data');
        return data;
      } else {
        throw Exception('명함 가져오기 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('getBusinessCard Error: $e');
    }
  }

   // Future<int> toggleCardPublicStatus(String userEmail, int cardNo) async {
   //   try {
   //     final response = await http.post(
   //       Uri.parse('$baseUrl/toggle-public'),
   //       headers: {"Content-Type": "application/json"},
   //       body: json.encode({
   //         'userEmail': userEmail,
   //         'cardNo': cardNo,
   //       }),
   //     );
   //
   //     if (response.statusCode == 200) {
   //       final data = jsonDecode(response.body);
   //       return data['isPublic']; // 서버에서 변경된 공개 상태를 반환한다고 가정
   //     } else {
   //       throw Exception('명함 공개 상태 변경 실패: ${response.statusCode}');
   //     }
   //   } catch (e) {
   //     print("명함 공개 상태 변경 실패: $e");
   //     throw Exception("toggleCardPublicStatus Error: $e");
   //   }
   // }
   // Future<void> updateCardsPublicStatus(
   //     String userEmail, List<int?> cardNos, bool makePublic) async {
   //   try {
   //     final response = await http.post(
   //       Uri.parse('$baseUrl/update-public-status'),
   //       headers: {"Content-Type": "application/json"},
   //       body: json.encode({
   //         'userEmail': userEmail,
   //         'cardNos': cardNos,
   //         'isPublic': makePublic ? 1 : 0,
   //       }),
   //     );
   //
   //     if (response.statusCode != 200) {
   //       throw Exception('명함 상태 업데이트 실패: ${response.statusCode}');
   //     }
   //   } catch (e) {
   //     print("명함 상태 업데이트 실패: $e");
   //     throw Exception("updateCardsPublicStatus Error: $e");
   //   }
   // }

   Future<void> updateCardsPublicStatus(List<Map<String, dynamic>> cardData) async {
     try {
       final response = await http.post(
         Uri.parse('$baseUrl/public'),
         headers: {"Content-Type": "application/json"},
         body: json.encode(cardData),
       );

       print('Server response: ${response.body}');

       if (response.statusCode == 200) {
         // 응답 본문이 비어있지 않은 경우에만 JSON 파싱 시도
         if (response.body.isNotEmpty) {
           try {
             var decodedResponse = jsonDecode(response.body);
             if (decodedResponse['success'] == true) {
               print('Cards public status updated successfully');
             } else {
               print('Failed to update cards public status: ${decodedResponse['message']}');
             }
           } catch (e) {
             // JSON 파싱 실패 시 응답 본문을 그대로 출력
             print('Failed to parse JSON response. Raw response: ${response.body}');
           }
         } else {
           print('Server returned an empty response');
         }
       } else {
         print('Failed to update cards public status. Status code: ${response.statusCode}');
       }
     } catch (e) {
       print('Error in updateCardsPublicStatus: $e');
     }
   }
   Future<bool> updateBusinessCard(BusinessCard card) async {
     try {
       print("updateBusinessCard: $card");
       final response = await http.put(
         Uri.parse('$baseUrl/front/update'),
         headers: {"Content-Type": "application/json; charset=UTF-8"},
         body: json.encode(card.toJson()),
       );

       if (response.statusCode == 200) {
         print("명함 업데이트 성공");
         return true;
       } else {
         throw Exception('명함 업데이트 실패: ${response.statusCode}');
       }
     } catch (e) {
       print("명함 업데이트 실패 $e");
       throw Exception("updateBusinessCard Error: $e");
     }
   }

   Future<bool> deleteCard(int cardNo) async {
     try {
       // 저장된 이메일 가져오기
       String? userEmail = await storage.read(key: 'email');
       if (userEmail == null) {
         throw Exception('사용자 이메일을 찾을 수 없습니다.');
       }

       // 요청 바디 생성
       Map<String, dynamic> requestBody = {
         'cardNo': cardNo,
         'userEmail': userEmail,
       };

       final response = await http.post(
         Uri.parse('$baseUrl/delete'),
         headers: {"Content-Type": "application/json"},
         body: json.encode(requestBody),
       );

       if (response.statusCode == 200) {
         print("명함 삭제 성공");
         return true;
       } else {
         throw Exception('명함 삭제 실패: ${response.statusCode}');
       }
     } catch (e) {
       print("명함 삭제 실패: $e");
       throw Exception("deleteCard Error: $e");
     }
   }
}
