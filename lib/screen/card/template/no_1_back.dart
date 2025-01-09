import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:mime/mime.dart';

class No1Back extends StatefulWidget {
  final BusinessCard cardInfo;
  final File? image;

  No1Back({
    super.key,
    required this.cardInfo,
    this.image,
  });

  @override
  State<No1Back> createState() => _No1BackState();
}

class _No1BackState extends State<No1Back> {
  File? _imageFile;
  String serverUrl = 'http://112.221.66.174:8001';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  // 네트워크에서 이미지를 다운로드하고 로컬 파일로 저장
  Future<void> _loadImage() async {
    if (widget.cardInfo.logoPath != null) {
      setState(() {
        isLoading = true;
      });

      String imageUrl = serverUrl + widget.cardInfo.logoPath!;

      try {
        final response = await http.get(
          Uri.parse(imageUrl),
        );

        if (response.statusCode == 200) {
          // MIME 타입에 따라 확장자를 동적으로 설정
          String? mimeType = lookupMimeType(widget.cardInfo.logoPath!);
          String fileExtension = mimeType?.split('/').last ?? 'jpg'; // 기본 확장자는 'jpg'

          // 다운로드한 파일을 로컬 파일로 저장
          final directory = await getApplicationDocumentsDirectory();
          final filePath =
              '${directory.path}/logo_${widget.cardInfo.cardNo}.$fileExtension';
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          setState(() {
            _imageFile = file;
          });
        } else {
          print("이미지 다운로드 실패: ${response.statusCode}, URL: $imageUrl");
        }
      } catch (e) {
        print("이미지 다운로드 오류: $e");
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      height: 230,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(255, 255, 255, 1.0),
            Color.fromRGBO(177, 221, 210, 1.0)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          widget.image == null && _imageFile == null
              ? Text(
            widget.cardInfo.companyName ?? "",
            style: const TextStyle(
                fontSize: 20,
                color: Colors.black87,
                fontWeight: FontWeight.w600),
          )
              : FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: 200,
              height: 190,
              child: Image.file(
                _imageFile == null ? widget.image! : _imageFile!,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
