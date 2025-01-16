import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:itdat/widget/card/qr_business_card_list.dart';
import 'business_card_List.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CardSelect extends StatefulWidget {
  final String source; // 'qr' 또는 'nfc'

  const CardSelect({Key? key, required this.source}) : super(key: key);

  @override
  _CardSelectState createState() => _CardSelectState();
}

class _CardSelectState extends State<CardSelect> {
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final storage = FlutterSecureStorage();
    String? email = await storage.read(key: 'user_email');
    setState(() {
      userEmail = email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.source == 'qr'
          ? null  // QR 스캔인 경우 AppBar를 표시하지 않음
          : AppBar(
        title: Text(AppLocalizations.of(context)!.scannercard),
      ),
      body: widget.source == 'qr' ? QrBusinessCardList(userEmail: userEmail!):BusinessCardList(userEmail: userEmail!),
    );
  }
}