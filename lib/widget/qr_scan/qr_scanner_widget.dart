import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/nfc_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../setting/waitwidget.dart';

class QRScannerWidget extends StatefulWidget {
  @override
  _QRScannerWidgetState createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  MobileScannerController? _controller;
  bool _isFlashOn = false;
  final NfcModel _nfcModel = NfcModel();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
      _controller?.toggleTorch();
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        final BarcodeCapture? capture = await _controller!.analyzeImage(image.path);
        if (capture != null && capture.barcodes.isNotEmpty) {
          _showQRCodeResult(capture.barcodes.first.rawValue ?? 'No data');
        } else {
          _showQRCodeResult(AppLocalizations.of(context)!.noQRCodeFound);
        }
      } catch (e) {
        print('Error analyzing image: $e');
        _showQRCodeResult(AppLocalizations.of(context)!.errorAnalyzingImage);
      }
    }
  }

  void _showQRCodeResult(String result) async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });
    try {
      print('Raw QR 코드 데이터: $result');
      List<String> parts = result.split(',');
      if (parts.length != 2) {
        throw FormatException(AppLocalizations.of(context)!.qrCodeFormatError);
      }
      Map<String, dynamic> qrData = {
        'CardNo': parts[0],
        'userEmail': parts[1],
      };

      final storage = FlutterSecureStorage();
      String? myEmail = await storage.read(key: 'email');
      print('저장된 이메일: $myEmail');

      Map<String, dynamic> formData = {
        'userEmail': qrData['userEmail'],
        'CardNo': qrData['CardNo'],
        'myEmail': myEmail,
      };

      if (formData['userEmail'].isEmpty || formData['CardNo'].isEmpty) {
        throw FormatException(AppLocalizations.of(context)!.missingQRData);
      }

      print('서버로 전송할 데이터: $formData');

      await _sendDataToServer(formData);

      _controller?.stop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.qrProcessSuccess)),
      );
      Navigator.of(context).pop();
    } catch (e) {
      print('QR 코드 데이터 처리 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.qrProcessError),
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.tryAgain,
            onPressed: _resetScanner,
          ),
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _sendDataToServer(Map<String, dynamic> data) async {
    try {
      await _nfcModel.processCardInfo(data);
      print('데이터가 성공적으로 서버로 전송되었습니다.');
    } catch (e) {
      print('서버로 데이터 전송 중 오류 발생: $e');
      throw e;
    }
  }

  void _resetScanner() {
    setState(() {
      _isProcessing = false;
    });
    _controller?.start();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              _showQRCodeResult(barcode.rawValue ?? 'No data');
            }
          },
        ),
        Positioned(
          top: 10,
          right: 10,
          child: IconButton(
            icon: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: _toggleFlash,
          ),
        ),
        CustomPaint(
          painter: ScannerOverlay(),
          child: Container(),
        ),
        Positioned(
          bottom: 5,
          left: 0,
          right: 0,
          child: Center(
            child: ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(
                Icons.image,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
              ),
              label: Text(
                AppLocalizations.of(context)!.image,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                // 여기에 추가적인 스타일 설정을 할 수 있습니다.
              ),
            ),
          ),
        ),
        if (_isProcessing)
          Container(
            color: Colors.black.withOpacity(0.5), // 배경 투명도를 조절합니다
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: WaitAnimationWidget()
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}



class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaSize = size.width * 0.15; // 스캔 영역의 크기 설정
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;
    final double right = left + scanAreaSize;
    final double bottom = top + scanAreaSize;

    final Paint cornerPaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final double cornerLength = scanAreaSize * 0.2; // 모서리 선의 길이를 스캔 영역 크기의 20%로 설정
    final double radius = 5; // 둥근 모서리의 반지름을 작게 설정

    // 약간 부드러운 모서리 그리기
    final Path path = Path();

    // 좌상단 모서리
    path.moveTo(left + cornerLength, top);
    path.lineTo(left + radius, top);
    path.quadraticBezierTo(left, top, left, top + radius);
    path.lineTo(left, top + cornerLength);

    // 우상단 모서리
    path.moveTo(right - cornerLength, top);
    path.lineTo(right - radius, top);
    path.quadraticBezierTo(right, top, right, top + radius);
    path.lineTo(right, top + cornerLength);

    // 좌하단 모서리
    path.moveTo(left, bottom - cornerLength);
    path.lineTo(left, bottom - radius);
    path.quadraticBezierTo(left, bottom, left + radius, bottom);
    path.lineTo(left + cornerLength, bottom);

    // 우하단 모서리
    path.moveTo(right, bottom - cornerLength);
    path.lineTo(right, bottom - radius);
    path.quadraticBezierTo(right, bottom, right - radius, bottom);
    path.lineTo(right - cornerLength, bottom);

    // 경로 그리기
    canvas.drawPath(path, cornerPaint);

    // 십자선 그리기를 위한 Paint 객체
    final Paint crossPaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2.0;

    // 스캔 영역 중앙에 십자선 그리기
    final double centerX = (left + right) / 2;
    final double centerY = (top + bottom) / 2;
    final double crossSize = scanAreaSize / 5; // 십자선 크기를 스캔 영역의 1/5로 설정

    // 가로선 그리기
    canvas.drawLine(
      Offset(centerX - crossSize / 2, centerY),
      Offset(centerX + crossSize / 2, centerY),
      crossPaint,
    );

    // 세로선 그리기
    canvas.drawLine(
      Offset(centerX, centerY - crossSize / 2),
      Offset(centerX, centerY + crossSize / 2),
      crossPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
