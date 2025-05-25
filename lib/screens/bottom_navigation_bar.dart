import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final String currentScreen;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, 
      currentIndex: _getCurrentIndex(), 
      onTap: (index) {
        
        switch (index) {
          case 0:
            if (currentScreen != 'ShopScreen') {
              Navigator.pushReplacementNamed(context, '/shop');
            }
            break;
          case 1:
            if (currentScreen != 'BadgesScreen') {
              Navigator.pushReplacementNamed(context, '/badges');
            }
            break;
          case 2:
            if (currentScreen != 'ChallengesScreen') {
              Navigator.pushReplacementNamed(context, '/challenges');
            }
            break;
          case 3:
            if (currentScreen != 'QRcodeGeneratorScreen') {
              Navigator.pushReplacementNamed(context, '/qrcode-generator');
            }
            break;
          case 4:
            if (currentScreen != 'SettingsScreen') {
              Navigator.pushReplacementNamed(context, '/settings');
            }
            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Shop',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.military_tech),
          label: 'Badges',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code),
          label: 'QR Code',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
      selectedItemColor: Colors.green, 
      unselectedItemColor: Colors.green.shade200, 
    );
  }

  
  int _getCurrentIndex() {
    switch (currentScreen) {
      case 'ShopScreen':
        return 0;
      case 'BadgesScreen':
        return 1;
      case 'ChallengesScreen':
        return 2;
      case 'QRcodeGeneratorScreen':
        return 3;
      case 'SettingsScreen':
        return 4;
      default:
        return 2; 
    }
  }
}