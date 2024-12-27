// import 'dart:async';
// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:itdat/models/card_model.dart';
// import 'package:itdat/screen/card/preview_screen.dart';
// import 'dart:io';
// import 'package:http/http.dart' as http;
//
// class FormScreen extends StatefulWidget {
//   final int templateId;
//   final String userId;
//
//   const FormScreen({
//     super.key,
//     required this.templateId,
//     required this.userId
//   });
//
//   @override
//   State<FormScreen> createState() => _FormScreenState();
// }
//
// class _FormScreenState extends State<FormScreen> {
//
//   final CardModel cardModel = CardModel();
//   final _formKey = GlobalKey<FormState>();
//   List<dynamic> _userInfo = [];
//   final Map<String, String> _cardInfo = {};
//   File? _logo;
//
//   final ImagePicker _picker = ImagePicker();
//
//   final TextEditingController _name = TextEditingController();
//   final TextEditingController _phone = TextEditingController();
//   final TextEditingController _email = TextEditingController();
//   final TextEditingController _companyName = TextEditingController();
//   final TextEditingController _companyNumber = TextEditingController();
//   final TextEditingController _companyAddress = TextEditingController();
//   final TextEditingController _companyFax = TextEditingController();
//   final TextEditingController _position = TextEditingController();
//   final TextEditingController _department = TextEditingController();
//   final TextEditingController _fax = TextEditingController();
//
//
//   String svgData = "";
//   Timer? _debounce; // 딜레이를 위한 Timer
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserInfo();
//     _name.addListener(() => _onInputChanged());
//     _phone.addListener(() => _onInputChanged());
//     _email.addListener(() => _onInputChanged());
//     _companyName.addListener(() => _onInputChanged());
//     _companyNumber.addListener(() => _onInputChanged());
//     _companyAddress.addListener(() => _onInputChanged());
//     _companyFax.addListener(() => _onInputChanged());
//     _position.addListener(() => _onInputChanged());
//     _department.addListener(() => _onInputChanged());
//   }
//
//
//   Future<void> _loadUserInfo() async {
//     final userData = await cardModel.getUserInfo(widget.userId);
//     setState(() {
//       _userInfo = userData;
//     });
//   }
//
//   // 입력 변경 시 호출되는 메서드
//   void _onInputChanged() {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();
//
//     // 500ms 딜레이 후 서버 요청
//     _debounce = Timer(const Duration(milliseconds: 500), () {
//       _submitForm(
//         _name.text,
//         _phone.text,
//         _email.text,
//         _companyName.text,
//         _companyNumber.text,
//         _companyAddress.text,
//         _companyFax.text,
//         _position.text,
//         _department.text,
//
//       );
//     });
//   }
//
//
//   Future<void> _pickLogo() async {
//     final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _logo = File(pickedFile.path);
//       });
//     }
//   }
//
//   // 서버 요청 메서드
//   Future<void> fetchSvg(String name, String title, String phone) async {
//     final url = Uri.parse("http://112.221.66.174:8001/card/save")
//         .replace(queryParameters: {
//       "name": name,
//       "title": title,
//       "phone": phone,
//     });
//
//     try {
//       final response = await http.get(url);
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           svgData = data["svg"]; // 서버에서 반환된 SVG 데이터
//         });
//       } else {
//         print("Error: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Error fetching SVG: $e");
//     }
//   }
//
//   @override
//   void dispose() {
//     _name.dispose();
//     _phone.dispose();
//     _email.dispose();
//     _debounce?.cancel(); // Timer 해제
//     super.dispose();
//   }
//
//
//   // Future<void> _submitForm() async {
//   //   if (_formKey.currentState!.validate() && _logo != null) {
//   //     _formKey.currentState!.save();
//   //
//   //     // 명함 정보 업데이트
//   //     _cardInfo.addAll({
//   //       'name': _name.text,
//   //       'phone': _phone.text,
//   //       'email': _email.text,
//   //       'companyName': _companyName.text,
//   //       'companyNumber': _companyNumber.text,
//   //       'companyAddress': _companyAddress.text,
//   //       'companyFax': _companyFax.text,
//   //       'position': _position.text,
//   //       'department': _department.text,
//   //     });
//   //
//   //     // 명함 생성 요청 보내기
//   //     final businessCard = await cardModel.createBusinessCard(
//   //       _cardInfo,
//   //       _logo!.path,
//   //       widget.templateId,
//   //       widget.userId
//   //     );
//   //
//   //     // 만들어진 명함 보기
//   //     if (businessCard.containsKey('svgUrl')) {
//   //       Navigator.push(
//   //         context,
//   //         MaterialPageRoute(builder: (_) => PreviewScreen(svgUrl: businessCard['svgUrl'])),
//   //       );
//   //     } else {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(content: Text('명함 생성 실패. 다시 시도해주세요.')),
//   //       );
//   //     }
//   //   }
//   // }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(title: Text("내 명함 만들기")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//               TextFormField(
//               controller: _name,
//               decoration: const InputDecoration(labelText: '이름'),
//               validator: (value) => value == null || value.isEmpty ? '이름 필수 입력' : null,
//             ),
//             TextFormField(
//               controller: _phone,
//               decoration: const InputDecoration(labelText: '핸드폰 번호'),
//               keyboardType: TextInputType.phone,
//               validator: (value) => value == null || value.isEmpty ? '핸드폰 번호 필수 입력' : null,
//             ),
//             TextFormField(
//               controller: _email,
//               decoration: const InputDecoration(labelText: '이메일'),
//             ),
//             TextFormField(
//               controller: _companyName,
//               decoration: const InputDecoration(labelText: '회사 이름'),
//             ),
//             TextFormField(
//               controller: _companyNumber,
//               decoration: const InputDecoration(labelText: '회사 연락처'),
//             ),
//             TextFormField(
//               controller: _companyAddress,
//               decoration: const InputDecoration(labelText: '회사 주소'),
//             ),
//             TextFormField(
//               controller: _companyFax,
//               decoration: const InputDecoration(labelText: '팩스 번호'),
//             ),
//             TextFormField(
//               controller: _department,
//               decoration: const InputDecoration(labelText: '부서'),
//             ),
//             TextFormField(
//               controller: _position,
//               decoration: const InputDecoration(labelText: '직급'),
//             ),
//             const SizedBox(height: 20),
//
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text('로고 선택', style: TextStyle(fontSize: 16),),
//                 const SizedBox(height: 10,),
//                 _logo != null ?
//                     Image.file(_logo!, width: 100, height: 100, fit: BoxFit.cover,)
//                     : const Text("선택된 로고가 없습니다."),
//                 const SizedBox(height: 10,),
//                 ElevatedButton.icon(
//                   onPressed: _pickLogo,
//                   icon: Icon(Icons.image),
//                   label: const Text("로고를 선택해주세요."),
//                 )
//               ],
//             ),
//             const SizedBox(height: 20,),
//             Expanded(child:
//             svgData.isNotEmpty
//                 ? SvgPicture.string(
//               svgData,
//               fit: BoxFit.contain,
//             )
//                 :
//             ElevatedButton(
//                 onPressed: _submitForm,
//                 child: const Text("명함 생성"))
//
//           ],
//         ),
//       ),
//       )
//     );
//   }
// }
//
//
