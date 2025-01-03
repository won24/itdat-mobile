import 'package:flutter/material.dart';
import 'address_webview_screen.dart';

class AddressSearch extends StatefulWidget {
  final TextEditingController addressController; // 주소 입력 필드 컨트롤러
  final TextEditingController detailedAddressController; // 상세주소 입력 필드 컨트롤러

  const AddressSearch({
    required this.addressController,
    required this.detailedAddressController,
    Key? key,
  }) : super(key: key);

  @override
  _AddressSearchState createState() => _AddressSearchState();
}

class _AddressSearchState extends State<AddressSearch> {
  bool _showDetailField = false; // 상세주소 필드 표시 여부

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 주소 입력 필드 (항상 표시)
        _buildStyledTextField(
          controller: widget.addressController,
          label: "주소",
          isRequired: true,
          hintText: "주소를 검색해주세요.",
          isReadOnly: true, // 읽기 전용 (주소 검색으로만 입력 가능)
        ),
        const SizedBox(height: 10),
        // 주소 검색 버튼
        Center(
          child: ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddressWebView(),
                ),
              );

              if (result != null && result is String) {
                setState(() {
                  widget.addressController.text = result; // 주소 필드에 선택된 주소 입력
                  _showDetailField = true; // 상세주소 필드 표시
                });
              }
            },
            child: const Text("주소 검색"),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              textStyle: TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // 상세 주소 입력 필드 (주소 선택 후 표시)
        if (_showDetailField)
          _buildStyledTextField(
            controller: widget.detailedAddressController,
            label: "상세 주소",
            isRequired: false,
            hintText: "상세 주소를 입력해주세요.",
          ),
      ],
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required bool isRequired,
    required String hintText,
    bool isReadOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (isRequired)
              Text(
                " *",
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          readOnly: isReadOnly,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
