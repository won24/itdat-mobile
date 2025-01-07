import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:itdat/models/BusinessCard.dart';

class LoadNo1Back extends StatefulWidget {
  final BusinessCard cardInfo;
  final String imageUrl;  // File -> String으로 변경

  const LoadNo1Back({
    super.key,
    required this.cardInfo,
    required this.imageUrl,  // File -> String으로 변경
  });

  @override
  State<LoadNo1Back> createState() => _LoadNo1BackState();
}

class _LoadNo1BackState extends State<LoadNo1Back> {


  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      height: 230,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromRGBO(255, 248, 194, 1.0), Color.fromRGBO(203, 255, 239, 1.0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          widget.imageUrl.isEmpty
              ? Text(widget.cardInfo.companyName ?? "",
              style: const TextStyle(fontSize: 20, color: Colors.black87, fontWeight: FontWeight.w600))
              : FittedBox(
            fit: BoxFit.contain, // 이미지의 비율을 유지하면서 크기 조절
            child: SizedBox(
              width: 200, // 최대 가로 크기
              height: 190, // 최대 세로 크기
              child: Image.network(
                widget.imageUrl, // 이제 URL을 사용
                fit: BoxFit.contain, // 이미지를 최대 크기에 맞춰 비율을 유지
              ),
            ),
          ),
        ],
      ),
    );
  }
}
