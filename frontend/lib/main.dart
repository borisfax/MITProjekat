import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:candy_shop/theme/app_theme.dart';
import 'package:candy_shop/screens/shop_shell.dart';
import 'package:candy_shop/screens/login_screen.dart';
import 'package:candy_shop/providers/cart_provider.dart';
import 'package:candy_shop/providers/auth_provider.dart';
import 'package:candy_shop/providers/order_provider.dart';

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
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: MaterialApp(
        title: 'Candy Shop',
        theme: AppTheme.lightTheme,
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (authProvider.isLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return (authProvider.isAuthenticated || authProvider.isGuest) ? const ShopShell() : const LoginScreen();
          },
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
