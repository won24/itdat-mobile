import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class No1Back extends StatefulWidget {
  final BusinessCard cardInfo;
  final File? image;

  const No1Back({
    super.key,
    required this.cardInfo,
    required this.image,
  });

  @override
  State<No1Back> createState() => _No1BackState();
}

class _No1BackState extends State<No1Back> {

  File? _imageFile;
  String? _bearerToken;

  @override
  void initState() {
    super.initState();
    _getToken();
  }


  Future<void> _getToken() async {
    final storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'auth_token');
    print("토큰 확인: $token");

    if (token != null) {
      _bearerToken = token;
      _loadImage(); // 토큰이 초기화되었을 때 이미지를 로드하도록 호출
    }
  }

  // 네트워크에서 이미지를 다운로드하고 로컬 파일로 저장
  Future<void> _loadImage() async {

    if (_bearerToken == null) {
      // 토큰이 없으면 이미지 로드를 시도하지 않음
      print("토큰이 없어서 이미지 로드 불가");
      return;
    }

    if (widget.cardInfo.logoPath != null) {
      // URL 경로를 파일로 다운로드
      String imageUrl = 'http://112.221.66.174:8001' + widget.cardInfo.logoPath!; // 서버 URL을 사용

      try {
        final response = await http.get(
            Uri.parse(imageUrl),
            headers: {
              'Authorization': 'Bearer $_bearerToken',  // 인증 토큰 추가
              'User-Agent': 'FlutterApp/1.0',  // User-Agent 추가
            },
        );

        if (response.statusCode == 200) {
          // 다운로드한 파일을 로컬 파일로 저장
          final directory = await getApplicationDocumentsDirectory();
          final filePath = '${directory.path}/logo_${widget.cardInfo.cardNo}.jpg';
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          // 다운로드한 이미지를 상태로 저장
          setState(() {
            _imageFile = file;
          });
        } else {
          print("이미지 다운로드 실패: ${response.statusCode}, URL: $imageUrl");
        }
      } catch (e) {
        print("이미지 다운로드 오류: $e");
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
              Color.fromRGBO(133, 200, 181, 1.0)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            widget.image == null || _imageFile == null
              ? Text(widget.cardInfo.companyName ?? "",
                    style: const TextStyle(fontSize: 20, color: Colors.black87, fontWeight:FontWeight.w600),
              )
              : FittedBox(
                  fit: BoxFit.contain, // 이미지의 비율을 유지하면서 크기 조절
                  child: SizedBox(
                    width: 200, // 최대 가로 크기
                    height: 190, // 최대 세로 크기
                    child: Image.file(
                      _imageFile == null
                          ? widget.image!
                        : _imageFile!,
                      fit: BoxFit.contain, // 이미지를 최대 크기에 맞춰 비율을 유지
                    ),
                  ),
              ),
          ],
        )
    );
  }
}
