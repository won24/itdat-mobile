import 'package:flutter/material.dart';
import 'package:itdat/models/report_model.dart';
import 'package:itdat/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class Reportuserwidget extends StatefulWidget {
  final String userEmail;
  const Reportuserwidget({
    super.key,
    required this.userEmail,
  });

  @override
  State<Reportuserwidget> createState() => _ReportuserwidgetState();
}

class _ReportuserwidgetState extends State<Reportuserwidget> {

  final String sendSmsUrl = "http://10.0.2.2:8082/api/sms/send";
  final String verifySmsUrl = "http://10.0.2.2:8082/api/sms/verify";

  final TextEditingController reasonForReporting = TextEditingController();
  String? loginedUserEmail;

  @override
  void initState() {
    super.initState();
    // Provider로부터 로그인된 이메일 가져오기
    loginedUserEmail = context.read<AuthProvider>().userEmail;
  }

   void sendReport () async {
       final String reason = reasonForReporting.text.trim();
       final String repotedUserEmail = widget.userEmail;
       // print("1111111111111111111111");
       // print(reason);
       // print(repotedUserEmail);
       // print(loginedUserEmail);

       if (reason.isEmpty) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("신고 이유를 입력해 주세요.")),
         );
       }else{
         bool result = await ReportModel().sendNewReport(reason, loginedUserEmail!, repotedUserEmail);

         if(result == true){
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text("신고가 접수되었습니다.")),
           );
           Navigator.of(context).pop(); // 다이얼로그 닫기
         } else {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text("신고가 반려되었습니다..")),
           );
           Navigator.of(context).pop();
         }



       }


   }

  @override
  Widget build(BuildContext context) {

    final loginedUserEmail = context.watch<AuthProvider>().userEmail;

    return AlertDialog(
      title: Text("유저 신고"),
      content: TextField(
        controller: reasonForReporting,
        decoration: InputDecoration(hintText: "신고 이유를 적어주세요."),
      ),
      actions: [
        TextButton(
            onPressed: sendReport,
            child: const Text("신고"),
        )
      ],
    );
  }

  @override
  void dispose() {
    reasonForReporting.dispose(); // 메모리 누수를 방지하기 위해 컨트롤러 해제
    super.dispose();
  }
}
