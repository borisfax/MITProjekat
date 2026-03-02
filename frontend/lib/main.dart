import 'package:flutter/material.dart';
import 'package:candy_shop/theme/app_theme.dart';
import 'package:candy_shop/screens/shop_shell.dart';

void main() {
  runApp(const CandyShopApp());
}

class CandyShopApp extends StatelessWidget {
  const CandyShopApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Candy Shop',
      theme: AppTheme.lightTheme,
      home: const ShopShell(),
      debugShowCheckedModeBanner: false,
    );
  }
}
