import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:itdat/utils/HttpClientManager.dart';

class TextFileViewer extends StatefulWidget {
  final String textFileUrl;

  TextFileViewer({required this.textFileUrl});

  @override
  _TextFileViewerState createState() => _TextFileViewerState();
}

class _TextFileViewerState extends State<TextFileViewer> {
  String _fileContent = "";

  @override
  void initState() {
    super.initState();
    _loadTextFile();
  }

  Future<void> _loadTextFile() async {
    final client = await HttpClientManager().createHttpClient();
    final response = await client.get(Uri.parse(widget.textFileUrl));

    if (response.statusCode == 200) {
      setState(() {
        _fileContent = response.body;
      });
    } else {
      setState(() {
        _fileContent = "파일을 불러오는 데 실패했습니다.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('문서 보기')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(_fileContent),
        ),
      ),
    );
  }
}
