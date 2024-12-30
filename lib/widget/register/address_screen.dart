import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'address_webview_screen.dart';

class AddressSearch extends StatefulWidget {
  final String address;
  final Function(String) setAddress;
  final String detailedAddress;
  final Function(String) setDetailedAddress;

  AddressSearch({
    required this.address,
    required this.setAddress,
    required this.detailedAddress,
    required this.setDetailedAddress,
  });

  @override
  _AddressSearchState createState() => _AddressSearchState();
}

class _AddressSearchState extends State<AddressSearch> {
  void _openAddressSearch() async {
    final selectedAddress = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddressWebView(),
      ),
    );

    // 주소가 선택되었을 때만 상태 업데이트
    if (selectedAddress != null && mounted) {
      setState(() {
        widget.setAddress(selectedAddress);
        widget.setDetailedAddress(''); // 상세 주소 초기화
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("회사 주소"),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: TextEditingController(text: widget.address),
                readOnly: true,
                decoration: InputDecoration(
                  hintText: "주소를 검색하세요",
                ),
              ),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: _openAddressSearch,
              child: Text("검색"),
            ),
          ],
        ),
        SizedBox(height: 16),
        if (widget.address.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("상세 주소"),
              TextField(
                controller: TextEditingController(text: widget.detailedAddress),
                onChanged: widget.setDetailedAddress,
                decoration: InputDecoration(
                  hintText: "상세 주소를 입력하세요",
                ),
              ),
            ],
          ),
      ],
    );
  }
}
