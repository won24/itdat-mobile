import 'package:flutter/material.dart';
import 'package:itdat/widget/card_templete/1st_card.dart';
import 'package:itdat/widget/my_card_screen/card_model.dart';


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
  TextEditingController _deparment = TextEditingController();
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
      body: Center(
        child: Expanded(child: FirstCard()),
      ),
    );
  }
}

