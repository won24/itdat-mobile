import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itdat/models/http_client_model.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class CardModel{
   final storage = FlutterSecureStorage();
   final baseUrl = "${dotenv.env['BASE_URL']}/card";


  void logError(String functionName, dynamic error) {
    print("[$functionName] Error: $error");
  }

  void handleResponse(http.Response response, String functionName) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      print("[$functionName] 성공");
    } else {
      var errorBody = utf8.decode(response.bodyBytes);
      print("[$functionName] 실패: ${response.statusCode} - $errorBody");
      throw Exception("[$functionName] Error: ${response.statusCode}");
    }
  }


  // 유저 정보로 명함 기본 정보 가져오기
  Future<Map<String, dynamic>> getUserById(String userEmail) async {
    final client = await HttpClientModel().createHttpClient();

    try {
      final response = await client.get(Uri.parse("$baseUrl/userinfo/$userEmail"));
      handleResponse(response, "getUserById");
      return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } catch (e) {
      logError("getUserById", e);
      throw Exception("getUserById Error: $e");
    }
  }

  // 로고 없는 명함 저장
  Future<BusinessCard> createBusinessCard(BusinessCard card) async {
    final client = await HttpClientModel().createHttpClient();

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/save'),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: json.encode(card.toJson()),
      );
      handleResponse(response, "createBusinessCard");
      return BusinessCard.fromJson(json.decode(response.body));
    } catch (e) {
      logError("createBusinessCard", e);
      throw Exception("createBusinessCard Error: $e");
    }
  }



  // 로고있는 명함 저장
  Future<void> saveBusinessCardWithLogo(BusinessCard cardInfo) async {
    final client = await HttpClientModel().createHttpClient();

    try {
      final url = Uri.parse('$baseUrl/save/logo');
      var request = http.MultipartRequest('POST', url);

      request.fields['cardInfo'] = jsonEncode(cardInfo.toJson()).trim();
      print("저장 할 카드정보 : ${request.fields['cardInfo']}");

      if (cardInfo.logoUrl != null && cardInfo.logoUrl!.isNotEmpty) {
        final logoFile = File(cardInfo.logoUrl!);
        final mimeType = lookupMimeType(logoFile.path) ?? 'application/octet-stream';
        final fileName = path.basename(logoFile.path);

        request.files.add(http.MultipartFile.fromBytes(
          'logo',
          await logoFile.readAsBytes(),
          contentType: MediaType.parse(mimeType),
          filename: fileName,
        ));
      }

      final response = await client.send(request);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print("saveBusinessCardWithLogo 성공");
      } else {
        final responseBody = await response.stream.bytesToString();
        print("saveBusinessCardWithLogo 실패: ${response.statusCode} - $responseBody");
        throw Exception("saveBusinessCardWithLogo Error: ${response.statusCode}");
      }
    } catch (e) {
      logError("saveBusinessCardWithLogo", e);
      throw Exception("saveBusinessCardWithLogo Error: $e");
    }
  }

  // 명함 가져오기
  Future<List<dynamic>> getBusinessCard(String userEmail) async {
    final client = await HttpClientModel().createHttpClient();

    try {
      final response = await client.get(Uri.parse("$baseUrl/$userEmail"));
      handleResponse(response, "getBusinessCard");
      return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    } catch (e) {
      logError("getBusinessCard", e);
      throw Exception("getBusinessCard Error: $e");
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
     final client = await HttpClientModel().createHttpClient();

     try {
       final response = await client.post(
         Uri.parse('$baseUrl/publicstatus'),
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
     final client = await HttpClientModel().createHttpClient();

     try {
       print("updateBusinessCard: $card");
       final response = await client.post(
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

   Future<bool> deleteCard(int cardId) async {
     final client = await HttpClientModel().createHttpClient();

     try {
       // 저장된 이메일 가져오기
       String? userEmail = await storage.read(key: 'user_email');
       if (userEmail == null) {
         throw Exception('사용자 이메일을 찾을 수 없습니다.');
       }

       // 요청 바디 생성
       Map<String, dynamic> requestBody = {
         'cardNo': cardId,
         'userEmail': userEmail,
       };
       print(requestBody);

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

   // 명함첩 - 메모 추가
  Future<void> saveMemo(Map<String, dynamic> card) async {
    final client = await HttpClientModel().createHttpClient();

    try {
      final response = await client.post(
          Uri.parse("$baseUrl/mywallet/cardmemo"),
          headers: {"Content-Type": "application/json; charset=UTF-8"},
          body: json.encode(card).trim()
      );
      handleResponse(response, "saveMemo");
    } catch (e) {
      logError("saveMemo", e);
      throw Exception("saveMemo Error: $e");
    }
  }

   Future<String?> loadMemo(Map<String, dynamic> card) async {
     final client = await HttpClientModel().createHttpClient();

     try {
       final response = await client.post(
         Uri.parse("$baseUrl/mywallet/loadmemo"),
         headers: {"Content-Type": "application/json; charset=UTF-8"},
         body: json.encode(card),
       );

       if (response.statusCode == 200) {
         // 서버에서 직접 문자열을 반환한다고 가정
         return response.body;
       } else {
         print("메모 로드 실패: ${response.statusCode}");
         return null;
       }
     } catch (e) {
       print("loadMemo Error: $e");
       throw Exception("loadMemo Error: $e");
     }
   }

}
