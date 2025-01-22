import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/models/card_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:itdat/screen/card/template/business/no_1.dart';
import 'package:itdat/screen/card/template/business/no_2.dart';
import 'package:itdat/screen/card/template/business/no_3.dart';
import 'package:itdat/screen/card/template/personal/no_1.dart';
import 'package:itdat/screen/card/template/personal/no_2.dart';

import '../../widget/setting/waitwidget.dart';
import 'form_screen.dart';


class TemplateSelectionScreen extends StatefulWidget {

  final String userEmail;

  const TemplateSelectionScreen({
    super.key,
    required this.userEmail,
  });

  @override
  State<TemplateSelectionScreen> createState() => _TemplateSelectionScreenState();
}

class _TemplateSelectionScreenState extends State<TemplateSelectionScreen> {

  Map<String, dynamic>? userData;
  late BusinessCard _card;
  late List<Widget> businessTemplates;
  late List<Widget> personalTemplates;
  bool isLoading = true;
  int cardNo = 1;
  String selectedTemplate = "";
  String selectedCategory = "Business";

  @override
  void initState() {
    super.initState();
    fetchUserDataAndBusinessCards();
  }


  Future<void> fetchUserDataAndBusinessCards() async {
    setState(() => isLoading = true);

    try {
      final fetchedUserData = await CardModel().getUserById(widget.userEmail);
      final fetchedBusinessCards = await CardModel().getBusinessCard(widget.userEmail);

      setState(() {
        userData = fetchedUserData;

        if (fetchedBusinessCards.isNotEmpty) {
          final latestCard = fetchedBusinessCards.reduce((a, b) {
            DateTime aDate = DateTime.parse(a['createdAt']);
            DateTime bDate = DateTime.parse(b['createdAt']);

            return aDate.isAfter(bDate) ? a : b;
          });
          cardNo = latestCard['cardNo'] + 1;
        } else {
          cardNo = 1;
        }

        _initializeCard();
      });
    } catch (e) {
      setState(() {
        userData = {};
        cardNo = 1;
        _initializeCard();
      });
    } finally {
      setState(() => isLoading = false);
    }
  }


  void _initializeCard() {
    _card = BusinessCard(
      appTemplate: "",
      userName: userData?['userName'] ?? "",
      phone: userData?['userPhone'] ?? "",
      email: userData?['userEmail'] ?? "",
      companyName: userData?['company'] ?? "",
      companyNumber: userData?['companyPhone'] ?? "",
      companyAddress:
      "${userData?['companyAddr'] ?? ""} ${userData?['companyAddrDetail'] ?? ""}",
      companyFax: userData?['companyFax'] ?? "",
      department: userData?['companyDept'] ?? "",
      position: userData?['companyRank'] ?? "",
      userEmail: widget.userEmail,
      cardNo: cardNo,
      cardSide: "FRONT",
      logoUrl: "",
      isPublic: userData?['isPublic'] ?? false,
    );


    businessTemplates = [
      No1(cardInfo: _card),
      No2(cardInfo: _card),
      No3(cardInfo: _card),
    ];

    personalTemplates = [
      PersonalNo1(cardInfo: _card),
      PersonalNo2(cardInfo: _card),
    ];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("템플릿 선택")),
      body: isLoading
          ? const Center(child: WaitAnimationWidget())
          : Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedCategory = "Business";
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedCategory == "Business"
                      ? Color.fromRGBO(0, 202, 145, 1)
                      : Colors.white,
                  foregroundColor: selectedCategory == "Business"
                      ? Colors.white
                      : Colors.black87,
                  side: BorderSide(
                    color: Color.fromRGBO(0, 202, 145, 1),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 3,
                ),
                child: Text("For Business", style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedCategory = "Personal";
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedCategory == "Personal"
                      ? Color.fromRGBO(0, 202, 145, 1)
                      : Colors.white,
                  foregroundColor: selectedCategory == "Personal"
                      ? Colors.white
                      : Colors.black87,
                  side: BorderSide(
                    color: Color.fromRGBO(0, 202, 145, 1),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 3,
                ),
                child: Text("For Personal", style: TextStyle(fontWeight: FontWeight.bold),),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: selectedCategory == "Business"
                  ? businessTemplates.length
                  : personalTemplates.length,
              itemBuilder: (context, i) {
                final template = selectedCategory == "Business"
                    ? businessTemplates[i]
                    : personalTemplates[i];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory == "Business"?
                      selectedTemplate = "No${i + 1}" : selectedTemplate = "PersonalNo${i + 1}";
                      _card = _card.copyWith(appTemplate: selectedTemplate);
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormScreen(cardInfo: _card),
                      ),
                    );
                  },
                  child: Transform.scale(
                    scale: 0.9,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: template,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

