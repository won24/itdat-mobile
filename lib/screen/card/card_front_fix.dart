import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/models/card_model.dart';
import 'package:itdat/screen/card/template/no_1.dart';
import 'package:itdat/screen/card/template/no_2.dart';
import 'package:itdat/screen/card/template/no_3.dart';

class CardFrontFix extends StatefulWidget {
  final BusinessCard cardInfo;

  const CardFrontFix({Key? key, required this.cardInfo}) : super(key: key);

  @override
  _CardFrontFixState createState() => _CardFrontFixState();
}

class _CardFrontFixState extends State<CardFrontFix> {
  final _formKey = GlobalKey<FormState>();
  late BusinessCard _updatedCard;

  @override
  void initState() {
    super.initState();
    _updatedCard = widget.cardInfo;
    print("이닛");
    print(widget.cardInfo);
  }

  Widget buildBusinessCard(BusinessCard cardInfo) {
    switch (cardInfo.appTemplate) {
      case 'No1':
        return No1(cardInfo: cardInfo);
      case 'No2':
        return No2(cardInfo: cardInfo);
      case 'No3':
        return No3(cardInfo: cardInfo);
      default:
        return No2(cardInfo: cardInfo);
    }
  }

  void _updateCard() async {
    if (_formKey.currentState!.validate()) {
      print(_updatedCard);
      try {
        final result = await CardModel().updateBusinessCard(_updatedCard);
        if (result) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('명함이 성공적으로 저장되었습니다.')),
          );
          Navigator.pop(context, _updatedCard);
        } else {
          throw Exception('명함 업데이트에 실패했습니다.');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('명함 저장 중 오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("명함 정보 입력")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: buildBusinessCard(_updatedCard),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: "이름",
                hint: "이름을 입력하세요",
                icon: Icons.person,
                initialValue: _updatedCard.userName,
                onChanged: (value) => _updatedCard.userName = value,
                validator: (value) => value?.isEmpty ?? true ? "이름을 입력하세요." : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: "연락처",
                hint: "연락처를 입력하세요",
                icon: Icons.phone,
                initialValue: _updatedCard.phone,
                onChanged: (value) => _updatedCard.phone = value,
                validator: (value) => value?.isEmpty ?? true ? "연락처를 입력하세요." : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: "이메일",
                hint: "이메일을 입력하세요",
                icon: Icons.email,
                initialValue: _updatedCard.email,
                onChanged: (value) => _updatedCard.email = value,
                validator: (value) => value?.isEmpty ?? true ? "이메일을 입력하세요." : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: "회사 이름",
                hint: "회사 이름을 입력하세요",
                icon: Icons.business,
                initialValue: _updatedCard.companyName,
                onChanged: (value) => _updatedCard.companyName = value,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: "회사 전화번호",
                hint: "회사 전화번호를 입력하세요",
                icon: Icons.call,
                initialValue: _updatedCard.companyNumber,
                onChanged: (value) => _updatedCard.companyNumber = value,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: "회사 주소",
                hint: "회사 주소를 입력하세요",
                icon: Icons.location_on,
                initialValue: _updatedCard.companyAddress,
                onChanged: (value) => _updatedCard.companyAddress = value,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: "회사 팩스",
                hint: "회사 팩스를 입력하세요",
                icon: Icons.fax,
                initialValue: _updatedCard.companyFax,
                onChanged: (value) => _updatedCard.companyFax = value,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: "부서",
                hint: "부서를 입력하세요",
                icon: Icons.group,
                initialValue: _updatedCard.department,
                onChanged: (value) => _updatedCard.department = value,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: "직책",
                hint: "직책을 입력하세요",
                icon: Icons.work,
                initialValue: _updatedCard.position,
                onChanged: (value) => _updatedCard.position = value,
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _updateCard,
                  child: const Text("저장"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required String? initialValue,
    required Function(String) onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}