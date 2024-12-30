import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';

class QRScannerWidget extends StatefulWidget {
  @override
  _QRScannerWidgetState createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  MobileScannerController? _controller;
  bool _isFlashOn = false;

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

  void _showQRCodeResult(String result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result)),
    );
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


