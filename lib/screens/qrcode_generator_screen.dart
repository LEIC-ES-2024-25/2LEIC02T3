import 'package:flutter/material.dart';
import 'bottom_navigation_bar.dart';

class QRcodeGeneratorScreen extends StatelessWidget {
  const QRcodeGeneratorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code'),
      ),
      body: const Center(
        child: Text('This is the QR Code Screen'),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        currentScreen: 'QRcodeGeneratorScreen',
      ),
    );
  }
}