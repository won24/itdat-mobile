import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NfcWritePage extends StatelessWidget {
  // 하드코딩된 사용자 정보
  final String name = "손정원";
  final String phone = "010-1234-5678";
  final String email = "son@example.com";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NFC'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('NFC 카드에 정보 쓰기'),
          onPressed: () => _writeNfc(context),
        ),
      ),
    );
  }

  void _writeNfc(BuildContext context) async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      _showAlert(context, 'NFC를 사용할 수 없습니다.');
      return;
    }

    _showAlert(context, 'NFC 카드를 태그해주세요.');

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var ndef = Ndef.from(tag);
      if (ndef == null || !ndef.isWritable) {
        _showAlert(context, '이 NFC 카드는 쓰기가 불가능합니다.');
        NfcManager.instance.stopSession();
        return;
      }

      NdefMessage message = NdefMessage([
        NdefRecord.createText('name: $name'),
        NdefRecord.createText('number: $phone'),
        NdefRecord.createText('email: $email'),
      ]);

      try {
        await ndef.write(message);
        _showAlert(context, '정보가 성공적으로 기록되었습니다.');
      } catch (e) {
        _showAlert(context, '오류가 발생했습니다: $e');
      } finally {
        NfcManager.instance.stopSession();
      }
    });
  }

  void _showAlert(BuildContext context, String message) {
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