import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ImageQRScannerWidget extends StatelessWidget {
  const ImageQRScannerWidget({Key? key}) : super(key: key);

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        final MobileScannerController controller = MobileScannerController();
        final BarcodeCapture? capture = await controller.analyzeImage(image.path);
        controller.dispose();

        if (capture != null && capture.barcodes.isNotEmpty) {
          _showAlert(context, 'Success', 'QR Code: ${capture.barcodes.first.rawValue}');
        } else {
          _showAlert(context, 'No QR Code Found', 'The selected image does not contain a valid QR code.');
        }
      } catch (e) {
        print('Error analyzing image: $e');
        _showAlert(context, 'Error', 'An error occurred while analyzing the image.');
      }
    }
  }

  void _showAlert(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pickImage(context);
    });

    return Container(); // 빈 컨테이너 반환
  }
}