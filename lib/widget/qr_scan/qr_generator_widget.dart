import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../card/qr_business_card_list.dart';
import '../setting/waitwidget.dart';

class QRGeneratorWidget extends StatefulWidget {
  @override
  _QRGeneratorWidgetState createState() => _QRGeneratorWidgetState();
}

class _QRGeneratorWidgetState extends State<QRGeneratorWidget> {
  final Future<String?> _emailFuture = _loadEmail();

  static Future<String?> _loadEmail() async {
    final storage = FlutterSecureStorage();
    return await storage.read(key: 'user_email');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<String?>(
        future: _emailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: WaitAnimationWidget());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == null) {
            return Center(child: Text('No email found'));
          } else {
            return QrBusinessCardList(userEmail: snapshot.data!);
          }
        },
      ),
    );
  }
}