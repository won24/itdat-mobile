
import 'package:flutter/material.dart';
import 'package:itdat/widget/card/business_card_widget.dart';
import 'package:itdat/widget/card/history_widget.dart';
import 'package:itdat/widget/card/info_widget.dart';
import 'package:itdat/widget/card/portfolio_widget.dart';


class MyCardScreen extends StatefulWidget {
  const MyCardScreen({super.key});

  @override
  State<MyCardScreen> createState() => _MyCardWidgetState();
}

class _MyCardWidgetState extends State<MyCardScreen> {

  final userEmail = "sksksk4502@naver.com";

  int _selectedIndex = 0;
  
  final List<Widget> _widgets = const[
    InfoWidget(),
    PortfolioWidget(),
    HistoryWidget()
  ];

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: 385,
            height: 240,
            child: BusinessCardWidget(userEmail: userEmail),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(onPressed: (){
                setState(() {
                  _selectedIndex=0;
                });},
                child: const Text("연락처"),),
              const Text("|"),
              TextButton(onPressed: () {
                setState(() {
                  _selectedIndex = 1;
                });}, child: const Text("포트폴리오")),
              const Text("|"),
              TextButton(onPressed: () {
                setState(() {
                  _selectedIndex = 2;
                });}, child: const Text("히스토리"))
            ],
          ),
          Expanded(child: _widgets[_selectedIndex]),
        ],
      ),
    );
  }
}
