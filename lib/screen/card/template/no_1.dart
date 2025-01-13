import 'dart:io';
import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:mime/mime.dart';

class No1 extends StatefulWidget {
  final BusinessCard cardInfo;
  final File? image;

  const No1({
    super.key,
    required this.cardInfo,
    this.image,
  });

  @override
  _No1State createState() => _No1State();
}

class _No1State extends State<No1> {
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
    if (widget.cardInfo.logoUrl != null) {
      setState(() {
        isLoading = true;
      });

      String imageUrl = serverUrl + widget.cardInfo.logoUrl!;

      try {
        final response = await http.get(
          Uri.parse(imageUrl),
        );

        if (response.statusCode == 200) {
          // MIME 타입에 따라 확장자를 동적으로 설정
          String? mimeType = lookupMimeType(widget.cardInfo.logoUrl!);
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
      width: 400,
      height: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const SizedBox(height: 10),
          widget.cardInfo.logoUrl == null
              ? Text( widget.cardInfo.companyName ?? "",
                  style: const TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w600),
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
          Text(
            widget.cardInfo.userName ?? "",
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.cardInfo.department ?? "",
                style: const TextStyle(color: Colors.black87),
              ),
              Text(
                widget.cardInfo.position ?? "",
                style: const TextStyle(color: Colors.black87),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.cardInfo.companyNumber != null && widget.cardInfo.companyNumber!.isNotEmpty)
                ...[
                  const Text("T.  ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                  Text(
                    widget.cardInfo.companyNumber ?? "",
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(width: 10),
                ],
              if (widget.cardInfo.phone != null && widget.cardInfo.phone!.isNotEmpty)
                ...[
                  const Text("M.  ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                  Text(
                    widget.cardInfo.phone ?? "",
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.cardInfo.companyFax != null && widget.cardInfo.companyFax!.isNotEmpty)
                ...[
                  const Text("F.  ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                  Text(
                    widget.cardInfo.companyFax ?? "",
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              if (widget.cardInfo.email != null && widget.cardInfo.email!.isNotEmpty)
                ...[
                  const SizedBox(width: 10),
                  const Text("E.  ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                  Text(
                    widget.cardInfo.email ?? "",
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],

            ],
          ),
          Text(
            widget.cardInfo.companyAddress ?? "",
            style: const TextStyle(color: Colors.black87,fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
