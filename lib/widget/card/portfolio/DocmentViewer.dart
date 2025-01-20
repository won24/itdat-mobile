import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class DocumentViewer extends StatelessWidget {
  final String documentUrl;

  DocumentViewer({

    required this.documentUrl
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('문서 보기')),
      body: PDFView(
        filePath: documentUrl,
      ),
    );
  }
}
