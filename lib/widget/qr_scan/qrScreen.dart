import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../card/cart_select_widget.dart';
import 'qr_scanner_widget.dart';
import 'qr_generator_widget.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({Key? key}) : super(key: key);

  @override
  _QRScanScreenState createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    QRScannerWidget(),
    QRGeneratorWidget(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.qrcodescan)),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        height: 150, // 원하는 높이로 조절
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner),
              label: AppLocalizations.of(context)!.scan,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code),
              label: AppLocalizations.of(context)!.generate,
            ),

          ],
          selectedItemColor: isDarkMode ? Colors.white : Colors.black,
          unselectedItemColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          selectedFontSize: 14,
          unselectedFontSize: 14,
          iconSize: 25,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
        ),
      ),
    );
  }
}