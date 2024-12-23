import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRGeneratorWidget extends StatefulWidget {
  @override
  _QRGeneratorWidgetState createState() => _QRGeneratorWidgetState();
}

class _QRGeneratorWidgetState extends State<QRGeneratorWidget> {
  final String name = "소니";
  final String phoneNumber = "+1234567890";
  String qrData = '';

  @override
  void initState() {
    super.initState();
    qrData = "Name: $name\nPhone: $phoneNumber";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),

          ],
        ),
      ),
    );
  }
}