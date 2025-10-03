import 'package:app_test/routes.dart';
import 'package:app_test/screens/splash_screen.dart';

import 'package:app_test/widgets/main_shell.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travel Booking',
      theme: ThemeData(
        primaryColor: const Color(0xFF0E4C45),
        scaffoldBackgroundColor: const Color(0xFFF5F8FB),
        fontFamily: 'SF Pro Display',
        useMaterial3: false,
      ),
      // Bắt đầu vào Splash trước
      initialRoute: Routes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
