import 'package:flutter/material.dart';
import 'package:itdat/screen/main/card_wallet_screen.dart';
import 'package:itdat/screen/main/my_card_screen.dart';
import 'package:itdat/screen/main/my_info_screen.dart';
import 'package:itdat/screen/main/open_card_screen.dart';
import 'package:itdat/widget/qr_scan/qrScreen.dart';
import 'package:itdat/widget/setting/settingWidget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widget/nfc/nfcRead.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    MyCardScreen(),
    CardWalletScreen(),
    OpenCardScreen(),
    MyInfoScreen(),
    //Settings()
  ];
  void onTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: AppBar(
          title: Image.asset(
            isDarkMode ? 'assets/logowhite.png' : 'assets/logoblack.png',
            fit: BoxFit.contain,
            height: 50, // 원하는 높이로 조정
          ),
          centerTitle: false,
          titleSpacing: 12,
          actions: [
            IconButton(
              icon: Image.asset(
                'assets/nfc.png',
                width: 25,
                height: 25,
                color: isDarkMode ? Colors.grey[200] : Colors.black,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NfcReadPage()),
                );
              },

            ),
            IconButton(
              icon: Image.asset(
                'assets/qr.png',
                width: 26,
                height: 26,
                color: isDarkMode ? Colors.grey[200] : Colors.black,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRScanScreen()),
                );
              },
            ),
            // IconButton(
            //   icon: Icon(Icons.settings, size: 28),
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => Settings()),
            //     );
            //   },
            // ),
            SizedBox(width: 12),
          ],
          toolbarHeight: 70,
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 62,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: onTapped,
          selectedFontSize: 14,
          unselectedFontSize: 12,
          selectedItemColor: isDarkMode ? Colors.white : Colors.black,
          unselectedItemColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.credit_card_sharp),
              label: AppLocalizations.of(context)!.myCard,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wallet_sharp),
              label: AppLocalizations.of(context)!.cardWallet,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_sharp),
              label: AppLocalizations.of(context)!.openCard,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_sharp),
              label: AppLocalizations.of(context)!.myInfo,
            ),
          ],
        ),
      ),
    );
  }
}