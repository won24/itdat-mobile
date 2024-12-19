import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  bool _isFlashOn = false;
  MobileScannerController? _controller;

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
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            print('Barcode found in image! ${barcode.rawValue}');
          }
          // 여기서 첫 번째 바코드 값을 사용하거나 필요에 따라 처리
          Navigator.pop(context, barcodes.first.rawValue);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No QR code found in the image')),
          );
        }
      } catch (e) {
        print('Error analyzing image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error analyzing image')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.qrcodescan)),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  child: MobileScanner(
                    controller: _controller,
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      for (final barcode in barcodes) {
                        print('Barcode found! ${barcode.rawValue}');
                      }
                      //여기서 이제 백으로 보내든 rawValue 실제값 가지고 핸들링하면됨
                      Navigator.pop(context);
                    },
                  ),
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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.image),
                  onPressed: _pickImage,
                ),
                IconButton(
                  icon: Icon(Icons.info),
                  onPressed: () {
                    // 정보 또는 도움말 표시
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaSize = size.width * 0.7;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;
    final double right = left + scanAreaSize;
    final double bottom = top + scanAreaSize;

    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final Rect scanRect = Rect.fromLTRB(left, top, right, bottom);
    canvas.drawRect(scanRect, borderPaint);

    // 반투명한 오버레이 그리기
    final Paint overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, top), overlayPaint);
    canvas.drawRect(Rect.fromLTWH(0, top, left, scanAreaSize), overlayPaint);
    canvas.drawRect(Rect.fromLTWH(right, top, left, scanAreaSize), overlayPaint);
    canvas.drawRect(Rect.fromLTWH(0, bottom, size.width, size.height - bottom), overlayPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}