import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NfcScreen extends StatefulWidget {
  const NfcScreen({Key? key}) : super(key: key);

  @override
  _NfcScreenState createState() => _NfcScreenState();
}

class _NfcScreenState extends State<NfcScreen> {
  final NfcManager _nfcManager = NfcManager.instance;
  bool _isReading = false;

  @override
  void initState() {
    super.initState();
    _initializeNFC();
  }

  Future<void> _initializeNFC() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      print('NFC is not available on this device');
      return;
    }
  }

  Future<void> _startNfcReadSession() async {
    setState(() {
      _isReading = true;
    });

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          var ndef = Ndef.from(tag);
          if (ndef == null) {
            _showAlertDialog('Error', 'This tag does not contain NDEF data.');
            return;
          }

          var records = await ndef.read();
          String name = '';
          String phone = '';
          String email = '';

          for (var record in records.records) {
            if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown) {
              if (record.type.length == 1 && record.type[0] == 0x54) { // 'T' for Text record
                var text = _decodeTextRecord(record);
                if (name.isEmpty) {
                  name = text;
                } else if (email.isEmpty) {
                  email = text;
                }
              } else if (record.type.length == 1 && record.type[0] == 0x55) { // 'U' for URI record
                var uri = _decodeUriRecord(record);
                if (record.payload[0] == 0x05) { // "tel:"
                  phone = uri;
                }
              }
            }
          }

          _showAlertDialog('명함 정보 수신', '이름: $name\n전화번호: $phone\n이메일: $email');
        } catch (e, stackTrace) {
          print('Error reading NFC: $e');
          print('Stack Trace: $stackTrace');
          _showAlertDialog('Error', 'Failed to read data from the tag.');
        } finally {
          NfcManager.instance.stopSession();
          setState(() {
            _isReading = false;
          });
        }
      },
    );
  }

  Future<void> _writeNfcTag() async {
    setState(() {
      _isReading = true;
    });

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          var ndef = Ndef.from(tag);
          if (ndef == null || !ndef.isWritable) {
            _showAlertDialog('Error', 'This tag is not writable.');
            return;
          }

          // 하드코딩된 명함 데이터
          String name = "John Doe";
          String phone = "010-1234-5678";
          String email = "john.doe@example.com";

          NdefMessage message = NdefMessage([
            NdefRecord.createText(name),
            NdefRecord.createUri(Uri.parse("tel:$phone")),
            NdefRecord.createText(email),
          ]);

          await ndef.write(message);
          _showAlertDialog('Success', 'NFC 태그에 데이터가 저장되었습니다.');
        } catch (e, stackTrace) {
          print('Error writing NFC: $e');
          print('Stack Trace: $stackTrace');
          _showAlertDialog('Error', 'Failed to write data to the tag.');
        } finally {
          NfcManager.instance.stopSession();
          setState(() {
            _isReading = false;
          });
        }
      },
    );
  }

  String _decodeTextRecord(NdefRecord record) {
    var languageCodeLength = record.payload[0] & 0x3f;
    return String.fromCharCodes(record.payload.sublist(languageCodeLength + 1));
  }

  String _decodeUriRecord(NdefRecord record) {
    return String.fromCharCodes(record.payload.sublist(1));
  }

  void _showAlertDialog(String title, String content) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC 명함 관리'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _isReading ? null : _startNfcReadSession,
              child: Text(_isReading ? 'NFC 태그를 읽는 중...' : 'NFC 명함 읽기'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isReading ? null : _writeNfcTag,
              child: Text(_isReading ? 'NFC 태그를 작성 중...' : 'NFC 명함 쓰기'),
            ),
            const SizedBox(height: 20),
            const Text(
              'NFC 태그를 기기 뒷면에 가까이 대세요.\n읽거나 작성 완료 후 알림이 표시됩니다.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
