import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:candy_shop/theme/app_theme.dart';
import 'package:candy_shop/screens/shop_shell.dart';
import 'package:candy_shop/providers/cart_provider.dart';
import 'package:candy_shop/providers/auth_provider.dart';

void main() {
  runApp(const CandyShopApp());
}

class CandyShopApp extends StatelessWidget {
  const CandyShopApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Candy Shop',
        theme: AppTheme.lightTheme,
        home: const ShopShell(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
