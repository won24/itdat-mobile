import 'package:flutter/material.dart';
import 'package:itdat/models/card_model.dart';


class BusinessCardWidget extends StatefulWidget {
  const BusinessCardWidget({super.key});

  @override
  State<BusinessCardWidget> createState() => _BusinessCardWidgetState();
}

class _BusinessCardWidgetState extends State<BusinessCardWidget> {
  
  final userCode = 1;

  TextEditingController _name = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _companyName = TextEditingController();
  TextEditingController _companyNumber = TextEditingController();
  TextEditingController _position = TextEditingController();
  TextEditingController _department = TextEditingController();
  TextEditingController _fax = TextEditingController();
  TextEditingController _logo = TextEditingController();

  final CardModel _cardModel = CardModel();
  List<dynamic> _userInfo = [];


  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() async{
    List<dynamic> userData = await _cardModel.searchUserInfo(userCode);
    setState(() {
      _userInfo = userData;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: _position,
              decoration: const InputDecoration(labelText: "Position"),
            ),
            TextField(
              controller: _department,
              decoration: const InputDecoration(labelText: "Department"),
            ),
            TextField(
              controller: _phone,
              decoration: const InputDecoration(labelText: "Phone"),
            ),
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _fax,
              decoration: const InputDecoration(labelText: "Fax"),
            ),
            TextField(
              controller: _companyName,
              decoration: const InputDecoration(labelText: "Company Name"),
            ),
            TextField(
              controller: _companyNumber,
              decoration: const InputDecoration(labelText: "Company Number"),
            ),
            TextField(
              controller: _logo,
              decoration: const InputDecoration(labelText: "Logo URL"),
            ),
            const SizedBox(height: 20),
            // SecondCard(
            //   nameController: _name,
            //   phoneController: _phone,
            //   emailController: _email,
            //   companyNameController: _companyName,
            //   companyNumberController: _companyNumber,
            //   positionController: _position,
            //   departmentController: _department,
            //   faxController: _fax,
            //   logoController: _logo,
            // ),
          ],
        ),
      ),
    );
  }
}

