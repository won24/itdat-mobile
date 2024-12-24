import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/models/card_model.dart';
import 'package:itdat/screen/card/preview_screen.dart';
import 'package:itdat/screen/card/template_selection_screen.dart';

class BusinessCardWidget extends StatefulWidget {
  final String userId;

  const BusinessCardWidget({
    super.key,
    required this.userId
  });

  @override
  State<BusinessCardWidget> createState() => _BusinessCardWidgetState();
}

class _BusinessCardWidgetState extends State<BusinessCardWidget> {
  late Future<List<BusinessCard>> _businessCards;

  @override
  void initState() {
    super.initState();
    _businessCards = CardModel().getBusinessCard(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<BusinessCard>>(
        future: _businessCards,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final businessCards = snapshot.data!;
          if (businessCards.isEmpty) {
            return Center(
                child:
                IconButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => TemplateSelectionScreen(userId: widget.userId)));
                }, icon: const Icon(Icons.add, size: 64,)),
            );
          }

          return ListView.builder(
            itemCount: businessCards.length,
            itemBuilder: (context, index) {
              final card = businessCards[index];
              return ListTile(
                title: Text(card.userName),
                subtitle: Text(card.companyName ?? 'No company name'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PreviewScreen(svgUrl: card.svgUrl),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
