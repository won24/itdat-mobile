import 'package:dio/dio.dart';

final String baseUrl = "http://112.221.66.174:8002"; // seo

class ReportModel {


  Future<bool> sendNewReport(String reason, String loginedUserEmail, String repotedUserEmail) async {
    final dio = Dio();

    try{
      final response = await dio.post('$baseUrl/admin/report-user',
          data: {reason, loginedUserEmail, repotedUserEmail}
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