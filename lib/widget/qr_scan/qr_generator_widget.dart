import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../card/cart_select_widget.dart';

class QRGeneratorWidget extends StatefulWidget {
  @override
  _QRGeneratorWidgetState createState() => _QRGeneratorWidgetState();
}

class _QRGeneratorWidgetState extends State<QRGeneratorWidget> {
  String? _myEmail;

  @override
  void initState() {
    super.initState();
    _loadEmail();

  }
  Future<void> _loadEmail() async {
    final storage = FlutterSecureStorage();
    _myEmail = await storage.read(key: 'email');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CardSelect(source: 'qr')
    );
  }
}