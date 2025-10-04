import 'package:app_test/widgets/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_test/firebase_options.dart';
import 'package:app_test/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const AuthGate(),
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
