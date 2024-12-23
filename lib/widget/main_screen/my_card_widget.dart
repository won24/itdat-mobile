
import 'package:flutter/material.dart';
import 'package:itdat/widget/my_card_screen/business_card_widget.dart';
import 'package:itdat/widget/my_card_screen/history_widget.dart';
import 'package:itdat/widget/my_card_screen/info_widget.dart';
import 'package:itdat/widget/my_card_screen/portfolio_widget.dart';

class MyCardWidget extends StatefulWidget {
  const MyCardWidget({super.key});

  @override
  State<MyCardWidget> createState() => _MyCardWidgetState();
}

class _MyCardWidgetState extends State<MyCardWidget> {
  
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
          Expanded(child:
            BusinessCardWidget(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(onPressed: (){
                setState(() {
                  _selectedIndex=0;
                });},
                child: Text("연락처"),),
              Text("|"),
              TextButton(onPressed: () {
                setState(() {
                  _selectedIndex = 1;
                });}, child: Text("포트폴리오")),
              Text("|"),
              TextButton(onPressed: () {
                setState(() {
                  _selectedIndex = 2;
                });}, child: Text("히스토리"))
            ],
          ),
          Expanded(child: _widgets[_selectedIndex]),
        ],
      ),
    );
  }
}
