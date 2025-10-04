import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/main_shell.dart';
import '../screens/login_screen.dart';
import '../screens/splash_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService
          .instance
          .authStateChanges, // hoặc FirebaseAuth.instance.authStateChanges()
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SplashScreen(
            autoNavigate: false,
          ); // đừng tự push sang Login ở đây
        }
        if (snap.hasError) {
          return const Scaffold(
            body: Center(child: Text('Có lỗi khi tải trạng thái đăng nhập')),
          );
        }
        return snap.data == null ? const LoginScreen() : const MainShell();
      },
    );
  }
}
