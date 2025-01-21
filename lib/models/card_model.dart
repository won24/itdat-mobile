import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itdat/utils/HttpClientManager.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class CardModel{
   final storage = FlutterSecureStorage();
   final baseUrl = "${dotenv.env['BASE_URL']}/card";



  Future<Map<String, dynamic>> getUserById(String userEmail) async {
    final client = await HttpClientManager().createHttpClient();

    try {
      final response = await client.get(Uri.parse("$baseUrl/userinfo/$userEmail"));
      return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } catch (e) {
      throw Exception("getUserById Error: $e");
    }
  }


  Future<BusinessCard> saveBusinessCard(BusinessCard card) async {
    final client = await HttpClientManager().createHttpClient();

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/save'),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: json.encode(card.toJson()),
      );
      return BusinessCard.fromJson(json.decode(response.body));
    } catch (e) {
      throw Exception("createBusinessCard Error: $e");
    }
  }


  Future<void> saveBusinessCardWithLogo(BusinessCard cardInfo) async {
    final client = await HttpClientManager().createHttpClient();

    try {
      final url = Uri.parse('$baseUrl/save/logo');
      var request = http.MultipartRequest('POST', url);

      request.fields['cardInfo'] = jsonEncode(cardInfo.toJson()).trim();

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
      print("response $response");

    } catch (e) {
      throw Exception("saveBusinessCardWithLogo Error: $e");
    }
  }


  Future<List<dynamic>> getBusinessCard(String userEmail) async {
    final client = await HttpClientManager().createHttpClient();

    try {
      final response = await client.get(Uri.parse("$baseUrl/$userEmail"));
      print(response.body);
      print("겟카드모델");
      return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    } catch (e) {
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
     final client = await HttpClientManager().createHttpClient();

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
     final client = await HttpClientManager().createHttpClient();

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
     final client = await HttpClientManager().createHttpClient();

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

       final response = await client.post(
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


  Future<void> saveMemo(Map<String, dynamic> card) async {
    final client = await HttpClientManager().createHttpClient();

    try {
      final response = await client.post(
          Uri.parse("$baseUrl/mywallet/cardmemo"),
          headers: {"Content-Type": "application/json; charset=UTF-8"},
          body: json.encode(card).trim()
      );
      print(response);
    } catch (e) {
      throw Exception("saveMemo Error: $e");
    }
  }

   Future<String?> loadMemo(Map<String, dynamic> card) async {
     final client = await HttpClientManager().createHttpClient();

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

   Future<BusinessCard?> editBusinessCard(BusinessCard card) async {
     final client = await HttpClientManager().createHttpClient();

     try {
       print("editBusinessCard: $card");
       final response = await client.post(
         Uri.parse('$baseUrl/front/update'),
         headers: {"Content-Type": "application/json; charset=UTF-8"},
         body: json.encode(card.toJson()),
       );

       if (response.statusCode == 200) {
         print("명함 업데이트 성공");
         return BusinessCard.fromJson(json.decode(response.body));
       } else if (response.statusCode == 400) {
         print("명함 업데이트 실패: ${response.body}");
         return null;
       } else {
         throw Exception('명함 업데이트 실패: ${response.statusCode}');
       }
     } catch (e) {
       print("명함 업데이트 실패 $e");
       throw Exception("editBusinessCard Error: $e");
     }
   }

   Future<BusinessCard?> editBusinessCardWithLogo(BusinessCard cardInfo) async {
     final client = await HttpClientManager().createHttpClient();

     try {
       final url = Uri.parse('$baseUrl/update/logo');
       var request = http.MultipartRequest('POST', url);

       // 카드 정보를 JSON으로 변환하여 추가
       request.fields['cardInfo'] = jsonEncode(cardInfo.toJson()).trim();

       // 로고 파일이 있는 경우 추가
       if (cardInfo.logoUrl != null && cardInfo.logoUrl!.isNotEmpty) {
         final logoFile = File(cardInfo.logoUrl!);
         final mimeType = lookupMimeType(logoFile.path) ?? 'application/octet-stream';
         final fileName = path.basename(logoFile.path);

         request.files.add(await http.MultipartFile.fromPath(
           'logo',
           logoFile.path,
           contentType: MediaType.parse(mimeType),
         ));
       }

       final streamedResponse = await client.send(request);
       final response = await http.Response.fromStream(streamedResponse);

       if (response.statusCode == 200) {
         print("로고 업데이트 성공");
       } else if (response.statusCode == 400) {
         print("로고 업데이트 실패: ${response.body}");
         return null;
       } else {
         throw Exception('로고 업데이트 실패: ${response.statusCode}');
       }
     } catch (e) {
       print("로고 업데이트 실패 $e");
       throw Exception("editBusinessCardWithLogo Error: $e");
     }
   }

}
