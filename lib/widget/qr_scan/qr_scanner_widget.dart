import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/nfc_model.dart';

class QRScannerWidget extends StatefulWidget {
  @override
  _QRScannerWidgetState createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  MobileScannerController? _controller;
  bool _isFlashOn = false;
  final NfcModel _nfcModel = NfcModel();
  bool _isProcessing = false; // 추가: QR 코드 처리 중인지 추적

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
          _showQRCodeResult('No QR code found in the image');
        }
      } catch (e) {
        print('Error analyzing image: $e');
        _showQRCodeResult('Error analyzing image');
      }
    }
  }

  void _showQRCodeResult(String result) async {
    if (_isProcessing) return; // 이미 처리 중이면 추가 처리 방지
    setState(() {
      _isProcessing = true; // 처리 시작
    });
    try {
      print('Raw QR 코드 데이터: $result');
      // 쉼표로 분리된 데이터 처리
      List<String> parts = result.split(',');
      if (parts.length != 2) {
        throw FormatException('QR 코드 데이터 형식이 올바르지 않습니다.');
      }
      Map<String, dynamic> qrData = {
        'CardNo': parts[0],
        'userEmail': parts[1],
      };

      // SecureStorage에서 현재 사용자의 이메일 가져오기
      final storage = FlutterSecureStorage();
      String? myEmail = await storage.read(key: 'email');
      print('저장된 이메일: $myEmail');

      if (myEmail == null || myEmail.isEmpty) {
        print('저장된 이메일이 없습니다. 다시 로그인해주세요.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 정보가 없습니다. 다시 로그인해주세요.')),
        );
        return;
      }

      // 폼 데이터 생성
      Map<String, dynamic> formData = {
        'userEmail': qrData['userEmail'],
        'CardNo': qrData['CardNo'],
        'myEmail': myEmail,
      };

      // 필수 데이터 확인
      if (formData['userEmail'].isEmpty || formData['CardNo'].isEmpty) {
        throw FormatException('QR 코드에 필요한 데이터가 누락되었습니다.');
      }

      print('서버로 전송할 데이터: $formData');

      // 서버로 데이터 전송
      await _sendDataToServer(formData);

      // 스캐너 일시 중지
      _controller?.stop();

      // 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('QR 코드 데이터가 성공적으로 처리되었습니다.')),
      );
      // CardWalletScreen으로 이동
      Navigator.of(context).pop();
    } catch (e) {
      print('QR 코드 데이터 처리 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('QR 코드 데이터 처리 중 오류가 발생했습니다.'),
          action: SnackBarAction(
            label: '다시 시도',
            onPressed: _resetScanner,
          ),
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false; // 처리 완료
      });
    }
  }

  Future<void> _sendDataToServer(Map<String, dynamic> data) async {
    try {
      await _nfcModel.processCardInfo(data); // NFCModel의 메서드를 사용하여 데이터 전송
      print('데이터가 성공적으로 서버로 전송되었습니다.');
    } catch (e) {
      print('서버로 데이터 전송 중 오류 발생: $e');
      throw e; // 상위 메서드에서 처리할 수 있도록 예외
    }
  }

  void _resetScanner() {
    setState(() {
      _isProcessing = false;
    });
    _controller?.start(); // 스캐너 재시작
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: (capture) {
            if (!_isProcessing) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                _showQRCodeResult(barcode.rawValue ?? 'No data');
                break; // 첫 번째 바코드만 처리
              }
            }
          },
        ),
        CustomPaint(
          painter: ScannerOverlay(),
          child: Container(),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: _toggleFlash,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
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
                'Image',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
              ),
            ),
          ),
        ),
        if (_isProcessing)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('처리 중...'),
              ],
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


