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
    final double scanAreaSize = size.width * 0.2; // Smaller box for the scan area
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;
    final double right = left + scanAreaSize;
    final double bottom = top + scanAreaSize;

    // Paint for the box border
    final Paint borderPaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 3.0;

    final double cornerLength = 20.0; // Corner line length

    // Draw corner lines for the box
    // Top-left corner
    canvas.drawLine(Offset(left, top), Offset(left + cornerLength, top), borderPaint);
    canvas.drawLine(Offset(left, top), Offset(left, top + cornerLength), borderPaint);

    // Top-right corner
    canvas.drawLine(Offset(right, top), Offset(right - cornerLength, top), borderPaint);
    canvas.drawLine(Offset(right, top), Offset(right, top + cornerLength), borderPaint);

    // Bottom-left corner
    canvas.drawLine(Offset(left, bottom), Offset(left + cornerLength, bottom), borderPaint);
    canvas.drawLine(Offset(left, bottom), Offset(left, bottom - cornerLength), borderPaint);

    // Bottom-right corner
    canvas.drawLine(Offset(right, bottom), Offset(right - cornerLength, bottom), borderPaint);
    canvas.drawLine(Offset(right, bottom), Offset(right, bottom - cornerLength), borderPaint);

    // Paint for the cross
    final Paint crossPaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2.0;

    // Draw the cross in the center of the box
    final double centerX = (left + right) / 2;
    final double centerY = (top + bottom) / 2;
    final double crossSize = scanAreaSize / 4; // Size of the cross arms

    // Horizontal line of the cross
    canvas.drawLine(
      Offset(centerX - crossSize / 2, centerY),
      Offset(centerX + crossSize / 2, centerY),
      crossPaint,
    );

    // Vertical line of the cross
    canvas.drawLine(
      Offset(centerX, centerY - crossSize / 2),
      Offset(centerX, centerY + crossSize / 2),
      crossPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
