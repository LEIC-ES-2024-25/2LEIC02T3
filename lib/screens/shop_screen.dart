import 'package:flutter/material.dart';
import 'bottom_navigation_bar.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
      ),
      body: const Center(
        child: Text('This is the Shop Screen'),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        currentScreen: 'ShopScreen',
      ),
    );
  }
}