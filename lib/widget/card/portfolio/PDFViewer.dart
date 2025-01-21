import 'dart:io';

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
      body: FutureBuilder(
        future: _checkIfFileExists(documentUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data == true) {
            return PDFView(
              filePath: documentUrl,
              swipeHorizontal: true,
              autoSpacing: false,
              pageFling: false,

            );
          } else {
            return Center(child: Text('파일을 찾을 수 없습니다.'));
          }
        },
      ),
    );
  }
}


Future<bool> _checkIfFileExists(String filePath) async {
  final file = File(filePath);
  bool exists = await file.exists();
  print('파일 존재 여부: $exists');
  return exists;
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

Future<String?> downloadAndSaveFileToExternalStorage(String url) async {
  try {
    final externalDir = await getExternalStorageDirectoryPath(); // 외부 저장소 경로 가져오기
    final filePath = '$externalDir/${url.split('/').last}';
    final dio = Dio();
    await dio.download(url, filePath);
    print("파일 저장 경로: $filePath");
    return filePath;
  } catch (e) {
    print('파일 다운로드 실패: $e');
    return null;
  }
}


Future<String> getExternalStorageDirectoryPath() async {
  final directory = await getExternalStorageDirectory();
  if (directory == null) {
    throw Exception('External storage directory is not available');
  }
  return directory.path;
}
