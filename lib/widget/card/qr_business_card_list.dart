import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart'; // 변경된 부분
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/models/card_model.dart';
import 'package:itdat/screen/card/template/business/no_1.dart';
import 'package:itdat/screen/card/template/business/no_2.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:itdat/screen/card/template/personal/no_1.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;

import '../setting/waitwidget.dart';

class QrBusinessCardList extends StatefulWidget {
  final String userEmail;

  const QrBusinessCardList({
    super.key,
    required this.userEmail,
  });

  @override
  State<QrBusinessCardList> createState() => _BusinessCardWidgetState();
}

class _BusinessCardWidgetState extends State<QrBusinessCardList> {
  late Future<dynamic> _businessCards;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _businessCards = CardModel().getBusinessCard(widget.userEmail);
  }

  // 명함 템플릿
  Widget buildBusinessCard(BusinessCard cardInfo) {
    switch (cardInfo.appTemplate) {
      case 'No1':
        return No1(cardInfo: cardInfo);
      case 'No2':
        return No2(cardInfo: cardInfo);
      case 'PersonalNo1':
        return PersonalNo1(cardInfo: cardInfo);
      default:
        return No1(cardInfo: cardInfo); // 기본값
    }
  }

  void _showQrCodeOverlay(BuildContext context, String qrData) {
    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _removeQrCodeOverlay,
        child: Container(
          color: Colors.black.withOpacity(0.7),
          child: Center(
            child: GestureDetector(
              onTap: () {}, // 이벤트 버블링 방지
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 300.0,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: ()=>_saveQrCodeWithCanvas(qrData, context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          side: BorderSide(
                            color: Color.fromRGBO(0, 202, 145, 1),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ).copyWith(
                          backgroundColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.pressed)) {
                              return Color.fromRGBO(0, 202, 145, 1);
                            }
                            if (states.contains(WidgetState.hovered)) {
                              return Color.fromRGBO(0, 202, 145, 1);
                            }
                            return Colors.white;
                          }),
                          foregroundColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.pressed)) {
                              return Colors.white;
                            }
                            return Colors.black87;
                          }),
                        ),
                        child: Text(
                            AppLocalizations.of(context)!.qrsave,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Future<void> _requestPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      // 권한이 없는 경우 요청
      await Permission.storage.request();
    }
  }

  Future<void> _saveQrCodeWithCanvas(String qrData, BuildContext context) async {
    await _requestPermission();
    try {
      final qrValidationResult = QrValidator.validate(
        data: qrData,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );

      if (qrValidationResult.status == QrValidationStatus.valid) {
        final qrCode = qrValidationResult.qrCode;
        final painter = QrPainter.withQr(
          qr: qrCode!,
          color: const Color(0xFF000000),
          emptyColor: const Color(0xFFFFFFFF),
          gapless: true,
        );

        const qrSize = 300.0;
        const padding = 40.0;
        const totalSize = qrSize + (padding * 2);

        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);

        // 배경 그리기
        final backgroundPaint = Paint()..color = Colors.white;
        canvas.drawRect(Rect.fromLTWH(0, 0, totalSize, totalSize), backgroundPaint);

        // QR 코드 그리기
        canvas.translate(padding, padding);
        painter.paint(canvas, Size(qrSize, qrSize));

        final picture = recorder.endRecording();
        final image = await picture.toImage(totalSize.toInt(), totalSize.toInt());
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final buffer = byteData!.buffer.asUint8List();

        // 갤러리에 이미지 저장
        final result = await ImageGallerySaverPlus.saveImage(Uint8List.fromList(buffer));

        if (result['isSuccess']) {
          ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(AppLocalizations.of(context)!.qrProcessSuccess)),
          );
        } else {
          throw Exception('이미지 저장 실패');
        }
      } else {
        throw Exception('QR 코드 생성 실패');
      }
    } catch (e) {
      print('QR 코드 저장 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.qrProcessError)),
      );
    }
  }

  void _removeQrCodeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _businessCards,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: WaitAnimationWidget());
        } else if (snapshot.hasError) {
          return  Center(child: Text(AppLocalizations.of(context)!.fetchCardsError));
        } else if (!snapshot.hasData || snapshot.data.isEmpty) {
          return  Center(child: Text(AppLocalizations.of(context)!.notfindcard));
        } else {
          var businessCards = snapshot.data;
          var frontCards = businessCards.where((card) => card['cardSide'] == "FRONT").toList();
          return ListView.builder(
            itemCount: frontCards.length,
            itemBuilder: (context, index) {
              var card = frontCards[index];
              BusinessCard cardInfo = BusinessCard(
                appTemplate: card['appTemplate'],
                userName: card['userName'],
                phone: card['phone'],
                email: card['email'],
                companyName: card['companyName'],
                companyNumber: card['companyNumber'],
                companyAddress: card['companyAddress'],
                companyFax: card['companyFax'],
                department: card['department'],
                position: card['position'],
                userEmail: card['userEmail'],
                cardNo: card['cardNo'],
                cardSide: card['cardSide'],
                logoUrl: card['logoUrl'],
                isPublic: card['isPublic'],
                backgroundColor: card['backgroundColor'],
                fontFamily: card['fontFamily'],
                textColor: card['textColor'],
              );
              return GestureDetector(
                onTap: () {
                  String qrData = '${cardInfo.cardNo},${cardInfo.email}';
                  _showQrCodeOverlay(context, qrData);
                },
                child: Transform.scale(
                  scale: 0.9,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: buildBusinessCard(cardInfo),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _removeQrCodeOverlay();
    super.dispose();
  }
}
