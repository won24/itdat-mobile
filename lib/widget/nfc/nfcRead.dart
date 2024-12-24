import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NfcReadPage extends StatefulWidget {
  @override
  _NfcReadPageState createState() => _NfcReadPageState();
}

class _NfcReadPageState extends State<NfcReadPage> {
  String _nfcData = '태그를 읽기 위해 NFC 카드를 기기에 가까이 대세요.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NFC 태그 읽기'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_nfcData),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('NFC 읽기 시작'),
              onPressed: _startNfcRead,
            ),
          ],
        ),
      ),
    );
  }

  void _startNfcRead() {
    setState(() {
      _nfcData = 'NFC 태그를 스캔하는 중...';
    });

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      try {
        var ndef = Ndef.from(tag);
        if (ndef == null) {
          setState(() {
            _nfcData = 'NFC 태그에 NDEF 데이터가 없습니다.';
          });
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
        setState(() {
          _nfcData = result.isNotEmpty ? result : 'NFC 태그를 읽었지만 텍스트 데이터가 없습니다.';
        });
      } catch (e) {
        setState(() {
          _nfcData = '오류가 발생했습니다: $e';
        });
      } finally {
        NfcManager.instance.stopSession();
      }
    });
  }
}