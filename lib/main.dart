// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/coin_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CoinProvider(),
      child: MaterialApp(
        title: 'Crypto Wallet',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Dark theme with black background and neon purple accents
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          primaryColor: Color(0xFFBF00FF), // Neon purple
          colorScheme: ColorScheme.dark(
            primary: Color(0xFFBF00FF), // Neon purple
            secondary: Color(0xFFBF00FF),
            surface: Color(0xFF1A1A1A), // Dark gray for cards
            background: Colors.black,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.black,
            elevation: 0,
            iconTheme: IconThemeData(color: Color(0xFFBF00FF)),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          cardColor: Color(0xFF1A1A1A),
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white70),
            titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        home: HomeScreen(),
      ),
    );
  }
}