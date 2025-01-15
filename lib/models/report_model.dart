import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final baseUrl = dotenv.env['BASE_URL'];

class ReportModel {

  Future<bool> sendNewReport(String reason, String loginedUserEmail, String reportedUserEmail, String selectedCategory) async {
    final dio = Dio();

    try{
      final response = await dio.post('$baseUrl/admin/report-user',
          data: {
            "reason":reason,
            "loginedUserEmail": loginedUserEmail,
            "reportedUserEmail": reportedUserEmail,
            "selectedCategory": selectedCategory,
          }
      );
      // true   "신고되었습니다."
      // false  "신고에 실패하였습니다."
      return response.data;
    }catch (e) {
      print("오류 발생: ${e.toString()}");
      return false;
    }

  }
  

  // Future<bool> sendReport() async {
  //   // 신고 로직
  //   final String reason = reasonForReporting.text.trim();
  //   final String userId;
  //   final String repotedUserId;
  //
  //   if (reason.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("신고 이유를 입력해 주세요.")),
  //     );
  //   }
  //
  //   // 여기에서 백엔드 요청을 보내세요.
  //   final response = await http.post(
  //     Uri.parse(sendSmsUrl),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({'phoneNumber': phoneNumber}),
  //   );
}