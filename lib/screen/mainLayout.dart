import 'package:flutter/material.dart';
import 'package:itdat/widget/main_screen/cardWalletWidget.dart';
import 'package:itdat/widget/main_screen/myCardWidget.dart';
import 'package:itdat/widget/main_screen/myInfoWidget.dart';
import 'package:itdat/widget/main_screen/openCardWidget.dart';
import 'package:itdat/widget/qr_scan/qrScreen.dart';
import 'package:itdat/widget/setting/settingWidget.dart';
import 'package:provider/provider.dart';
import 'package:itdat/providers/locale_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    myCard(),
    cardWallet(),
    openCard(),
    myInfo()
  ];
  void onTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _changeLanguage(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLocale = provider.locale;
    if (currentLocale.languageCode == 'en') {
      provider.setLocale(Locale('ko'));
    } else {
      provider.setLocale(Locale('en'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ITDAT',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.nfc_rounded),
            onPressed: () {
              // NFC 아이콘 클릭 이벤트
            },
          ),
          IconButton(
            icon: Icon(Icons.qr_code),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QRScanScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Settings()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.change_circle),
            onPressed: () => _changeLanguage(context),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: onTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card_rounded),
            label: AppLocalizations.of(context)!.myCard,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: AppLocalizations.of(context)!.cardWallet,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_rounded),
            label: AppLocalizations.of(context)!.openCard,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: AppLocalizations.of(context)!.myInfo,
          ),
        ],
      ),
    );
  }
}