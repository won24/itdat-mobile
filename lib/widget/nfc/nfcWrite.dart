import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:vibration/vibration.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:async';
import 'dart:convert';

class NfcWritePage extends StatefulWidget {
  final Map<String, dynamic> cardInfo;

  const NfcWritePage({Key? key, required this.cardInfo}) : super(key: key);

  @override
  _NfcWritePageState createState() => _NfcWritePageState();
}

class _NfcWritePageState extends State<NfcWritePage> {
  bool _isWriting = false;
  bool _isRetryVisible = false;
  Timer? _vibrationTimer;
  String _baseText = '';  // 초기값을 빈 문자열로 설정
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
    _baseText = AppLocalizations.of(context)!.nfctag;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.nfcwrite),
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
        final storage = FlutterSecureStorage();
        String? myEmail = await storage.read(key: 'email');
        if (myEmail == null || myEmail.isEmpty) {
          throw Exception('저장된 이메일이 없습니다. 다시 로그인해주세요.');
        }
        // cardInfo에서 userEmail과 CardNo만 추출
        Map<String, dynamic> nfcData = {
          'userEmail': widget.cardInfo['userEmail'],
          'CardNo': widget.cardInfo['cardNo'],
          //'myEmail' : myEmail
          'myEmail': "user16@example.com"
        };
        // 추출된 데이터를 JSON 문자열로 변환
        String nfcDataJson = json.encode(nfcData);
        // NFC 태그 데이터 쓰기 로직
        NdefMessage message = NdefMessage([
          NdefRecord.createText(nfcDataJson),
        ]);

        await ndef.write(message);
        _showAlert('명함 데이터가 성공적으로 기록되었습니다.');
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