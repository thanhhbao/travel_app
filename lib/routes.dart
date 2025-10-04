import 'package:flutter/material.dart';
import 'package:app_test/screens/splash_screen.dart';
import 'package:app_test/screens/login_screen.dart';
import 'package:app_test/widgets/main_shell.dart';

class Routes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return _fade(const SplashScreen());
      case Routes.login:
        return _fade(const LoginScreen());
      case Routes.home:
        return _fade(const MainShell());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }

  static PageRoute _fade(Widget page) => PageRouteBuilder(
    pageBuilder: (_, animation, __) => page,
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: const Duration(milliseconds: 250),
  );
}
