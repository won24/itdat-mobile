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
  String _baseText = 'NFC 태그를\n가까이 가져다 주세요';
  String _dots = '';
  Timer? _textAnimationTimer;

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
                    flex: 3,
                    child: _isWriting
                        ? Lottie.asset('assets/nfcAnime.json')
                        : SizedBox.shrink(),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
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
                onPressed: () {
                  setState(() {
                    _isRetryVisible = false;
                  });
                  _startNfcWrite();
                },
                tooltip: '다시 시도',
              ),
          ],
        ),
      ),
    );
  }

  void _startNfcWrite() {
    setState(() {
      _isWriting = true;
    });

    _startVibration();

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      try {
        var ndef = Ndef.from(tag);
        if (ndef == null || !ndef.isWritable) {
          _showAlert('이 NFC 태그는 쓰기가 불가능합니다.');
          return;
        }

        // NFC 태그 데이터 쓰기 로직
        NdefMessage message = NdefMessage([
          NdefRecord.createText('Sample Data'),
          // 여기에 더 많은 데이터를 추가할 수 있습니다.
        ]);

        await ndef.write(message);
        _showAlert('데이터가 성공적으로 기록되었습니다.');
      } catch (e) {
        _showAlert('NFC 쓰기 오류: $e');
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
    NfcManager.instance.stopSession();
    _stopVibration();
    _textAnimationTimer?.cancel();
    setState(() {
      _isWriting = false;
    });
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}