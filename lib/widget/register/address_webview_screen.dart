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
        'Flutter',
        onMessageReceived: (message) {
          final address = message.message;
          print("받은 주소: $address");
          Navigator.pop(context, address); // 주소 반환
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
            new daum.Postcode({
              oncomplete: function(data) {
                const address = data.address;
                console.log("선택한 주소: " + address);
                Flutter.postMessage(address);
              }
            }).embed(document.getElementById('layer'));
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
