import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:vibration/vibration.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

class NfcWritePage extends StatefulWidget {
  @override
  _NfcWritePageState createState() => _NfcWritePageState();
}

class _NfcWritePageState extends State<NfcWritePage> {
  bool _isWriting = false;
  bool _isRetryVisible = false;
  Timer? _vibrationTimer;
  String _baseText = 'NFC 카드를\n가까이 가져다 주세요';
  String _dots = '';
  Timer? _textAnimationTimer;

  // 하드코딩된 사용자 정보
  final String name = "손정원";
  final String phone = "010-1234-5678";
  final String email = "son@example.com";

  @override
  void initState() {
    super.initState();
    _startNfcWrite();
    _startTextAnimation();
  }

  @override
  void dispose() {
    _stopVibration();
    _textAnimationTimer?.cancel();
    NfcManager.instance.stopSession();
    super.dispose();
  }

  void _startTextAnimation() {
    _textAnimationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _dots = _dots.length >= 3 ? '' : _dots + '.';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NFC 쓰기'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 2 / 2,
              child: Column(
                children: [
                  Expanded(
                    flex: 5,
                    child: _isWriting
                        ? Lottie.asset('assets/nfcAnime.json')
                        : SizedBox.shrink(),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          children: [
                            TextSpan(text: _baseText),
                            TextSpan(text: _dots),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isRetryVisible)
              IconButton(
                icon: Icon(Icons.refresh),
                iconSize: 48,
                onPressed: _startNfcWrite,
                tooltip: '다시 시도',
              ),
          ],
        ),
      ),
    );
  }

  void _startNfcWrite() async {
    setState(() {
      _isWriting = true;
      _isRetryVisible = false;
    });

    _startVibration();

    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      _showAlert('NFC를 사용할 수 없습니다.');
      _stopNfcWrite();
      return;
    }

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var ndef = Ndef.from(tag);
      if (ndef == null || !ndef.isWritable) {
        _showAlert('이 NFC 카드는 쓰기가 불가능합니다.');
        _stopNfcWrite();
        return;
      }

      try {
        // NFC 데이터 쓰기 로직
        // NdefMessage message = NdefMessage([
        //   NdefRecord.createText('name: $name'),
        //   NdefRecord.createText('number: $phone'),
        //   NdefRecord.createText('email: $email'),
        // ]);
        // await ndef.write(message);
        
        _showAlert('정보가 성공적으로 기록되었습니다.');
      } catch (e) {
        _showAlert('오류가 발생했습니다: $e');
      } finally {
        _stopNfcWrite();
      }
    });

    // 30초 후에 자동으로 중지 및 "다시 시도" 버튼 표시
    Future.delayed(Duration(seconds: 30), () {
      if (_isWriting) {
        _stopNfcWrite();
        setState(() {
          _isRetryVisible = true;
        });
      }
    });
  }

  void _stopNfcWrite() {
    setState(() {
      _isWriting = false;
    });
    _stopVibration();
    NfcManager.instance.stopSession();
  }

  void _startVibration() async {
    if (await Vibration.hasVibrator() ?? false) {
      _vibrationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        Vibration.vibrate(duration: 100);
      });
    }
  }

  void _stopVibration() {
    _vibrationTimer?.cancel();
    Vibration.cancel();
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            child: Text('확인'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}