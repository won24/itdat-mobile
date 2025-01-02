import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AddressWebView extends StatefulWidget {
  @override
  _AddressWebViewState createState() => _AddressWebViewState();
}

class _AddressWebViewState extends State<AddressWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'sendAddress',
        onMessageReceived: (JavaScriptMessage message) {
          final address = message.message;
          print("받은 주소: $address");
          Navigator.pop(context, address); // Flutter로 주소 전달 후 닫기
        },
      )
      ..loadRequest(Uri.parse('data:text/html;charset=utf-8,' +
          Uri.encodeComponent('''
          <!DOCTYPE html>
          <html lang="ko">
          <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>주소 검색</title>
            <script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
          </head>
          <body>
            <div id="layer" style="width:100%;height:100%;"></div>
            <script>
              (function() {
                const targetOrigin = "*"; // 유효한 origin을 명시적으로 설정
                new daum.Postcode({
                  oncomplete: function(data) {
                    const address = data.address;
                    console.log("선택한 주소: " + address);

                    // Flutter로 메시지 전송
                    if (window.sendAddress) {
                      window.sendAddress.postMessage(address);
                    } else {
                      console.error("sendAddress 채널이 정의되지 않았습니다.");
                    }
                  }
                }).embed(document.getElementById('layer'));
              })();
            </script>
          </body>
          </html>
        ''')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('주소 검색'),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
