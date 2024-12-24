import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:vibration/vibration.dart';
import 'dart:async';
import 'dart:math' as math;

class NfcReadPage extends StatefulWidget {
  @override
  _NfcReadPageState createState() => _NfcReadPageState();
}

class _NfcReadPageState extends State<NfcReadPage> with SingleTickerProviderStateMixin {
  String _nfcData = '태그를 읽기 위해 NFC 카드를 기기에 가까이 대세요.';
  bool _isReading = false;
  late AnimationController _animationController;
  Timer? _vibrationTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 30),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _stopVibration();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NFC 읽기'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_isReading)
              Container(
                width: 100,
                height: 100,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: CircularProgressPainter(
                        progress: _animationController.value,
                        color: Theme.of(context).primaryColor,
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 20),
            Text(_nfcData),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text(_isReading ? 'NFC 읽기 중지' : 'NFC 읽기 시작'),
              onPressed: _isReading ? _stopNfcRead : _startNfcRead,
            ),
          ],
        ),
      ),
    );
  }

  void _startNfcRead() {
    setState(() {
      _isReading = true;
      _nfcData = 'NFC 태그를 스캔하는 중...';
    });

    _animationController.reset();
    _animationController.forward();

    _startVibration();

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      try {
        var ndef = Ndef.from(tag);
        if (ndef == null) {
          _updateNfcData('NFC 태그에 NDEF 데이터가 없습니다.');
          return;
        }

        var records = await ndef.read();
        String result = '';
        for (var record in records.records) {
          if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown && 
              record.type.length == 1 && 
              record.type[0] == 0x54) {  // 'T' for Text record
            var languageCodeLength = record.payload[0] & 0x3f;
            var text = String.fromCharCodes(record.payload.sublist(languageCodeLength + 1));
            result += '$text\n';
          }
        }
        
        _updateNfcData(result.isNotEmpty ? result : 'NFC 태그를 읽었지만 데이터가 없습니다.');
      } catch (e) {
        _updateNfcData('오류가 발생했습니다: $e');
      } finally {
        _stopNfcRead();
      }
    });

    // 30초 후에 자동으로 중지
    Future.delayed(Duration(seconds: 30), () {
      if (_isReading) {
        _stopNfcRead();
        _updateNfcData('태그를 읽기 위해 NFC 카드를 기기에 가까이 대세요.');
      }
    });
  }

  void _stopNfcRead() {
    NfcManager.instance.stopSession();
    _animationController.stop();
    _stopVibration();
    setState(() {
      _isReading = false;
    });
  }

  void _updateNfcData(String message) {
    setState(() {
      _nfcData = message;
    });
    _showAlert(message);
  }

  void _startVibration() {
    _stopVibration();
    _vibrationTimer = Timer.periodic(Duration(milliseconds: 1400), (timer) {
      Vibration.vibrate(duration: 150);
    });
  }

  void _stopVibration() {
    _vibrationTimer?.cancel();
    Vibration.cancel();
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('NFC 태그 정보'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircularProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double radius = math.min(size.width, size.height) / 2;
    Offset center = Offset(size.width / 2, size.height / 2);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}