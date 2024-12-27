import 'package:flutter/material.dart';

class PreviewScreen extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String? logoPath;
  final String templateUrl;

  const PreviewScreen({
    super.key,
    required this.userData,
    required this.logoPath,
    required this.templateUrl
  });

  String generateSvg(Map<String, dynamic> userData) {
    return """
    <svg xmlns="http://www.w3.org/2000/svg" width="400" height="300">
      <text x="10" y="30" font-size="20">${userData['name']}</text>
      <text x="10" y="60" font-size="15">${userData['position']} - ${userData['department']}</text>
      <text x="10" y="90" font-size="12">${userData['phone']}</text>
      <text x="10" y="120" font-size="12">${userData['email']}</text>
      <text x="10" y="150" font-size="12">${userData['companyName']}</text>
      <text x="10" y="180" font-size="12">${userData['companyAddress']}</text>
      <text x="10" y="210" font-size="12">Tel: ${userData['companyNumber']} Fax: ${userData['companyFax']}</text>
    </svg>
    """;
  }


  @override
  Widget build(BuildContext context) {
    String svgContent = generateSvg(userData);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              child: Text(svgContent, style: TextStyle(fontSize: 12)),
            ),
            ElevatedButton(
              onPressed: () {
                // 저장
              },
              child: Text("명함 추가"),
            ),
          ],
        ),
      ),
    );
  }
}