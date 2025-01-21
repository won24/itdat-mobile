import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class PDFViewer extends StatelessWidget {
  final String documentUrl;

  PDFViewer({
    super.key,
    required this.documentUrl
  });


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PDF 문서 보기')),
      body: PDFView(
        filePath: documentUrl,
      ),
    );
  }
}


Future<String?> downloadAndSaveFile(String url) async {
  try {
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/${url.split('/').last}';
    final dio = Dio();
    await dio.download(url, filePath);
    return filePath;
  } catch (e) {
    print('PDF 다운로드 실패: $e');
    return null;
  }
}
