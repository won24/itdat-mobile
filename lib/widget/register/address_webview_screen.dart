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
        'flutter_inappwebview', // JavaScript 채널 이름
        onMessageReceived: (JavaScriptMessage message) {
          final address = message.message;
          print("받은 주소: $address");

          // WebView에서 받은 주소를 Flutter로 전달
          Navigator.pop(context, address); // 주소 전달 후 WebView 닫기
        },
      )
      ..loadHtmlString(''' 
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
          const postcode = new daum.Postcode({
            oncomplete: function(data) {
              const address = data.address; // 선택한 주소
              console.log("선택한 주소: " + address);

              // WebView에 메시지 전달
              if (window.flutter_inappwebview) {
                window.flutter_inappwebview.postMessage(address);
              } else {
                console.error("flutter_inappwebview 채널이 정의되지 않았습니다.");
              }
            },
            alwaysShowEngAddr: false,
          });
          postcode.embed(document.getElementById('layer'));
        })();
      </script>
    </body>
    </html>
  ''');
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('주소 검색'),
      ),
      body: WebViewWidget(
        controller: _controller,
      ),
    );
  }
}
