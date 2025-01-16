import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/models/card_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:itdat/screen/card/form_screen.dart';
import 'package:itdat/screen/card/template/no_1.dart';
import 'package:itdat/screen/card/template/no_2.dart';
import 'package:itdat/screen/card/template/no_3.dart';

import '../../widget/setting/waitwidget.dart';


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
  late List<Widget> templates;
  bool isLoading = true;
  int cardNo = 1;
  String selectedTemplate = "";

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


    templates = [
      No1(cardInfo: _card),
      No2(cardInfo: _card),
      No3(cardInfo: _card),
    ];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.templateselect)),
      body: isLoading
          ? const Center(child: WaitAnimationWidget())
          : ListView.builder(
            itemCount: templates.length,
            itemBuilder: (context, i) {
              final template = templates[i];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTemplate = "No${i + 1}";
                    _card = _card.copyWith(appTemplate: selectedTemplate);
                  });
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormScreen(cardInfo: _card),
                      )
                  );
                },
                child: Transform.scale(
                  scale: 0.9,
                  child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: template
                  ),
                )
              );
            },
          ),
    );
  }
}

