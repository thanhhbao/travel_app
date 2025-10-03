import 'package:app_test/screens/login_screen.dart';
import 'package:app_test/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_test/screens/splash_screen.dart'; // chứa SplashScreen + LoginScreen + SignUpScreen
import 'package:app_test/widgets/main_shell.dart'; // chứa MainShell (home với bottom bar)

class Routes {
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return _m(const SplashScreen(), settings);
      case Routes.login:
        return _m(const LoginScreen(), settings);
      case Routes.signup:
        return _m(const SignUpScreen(), settings);
      case Routes.home:
        return _m(const MainShell(), settings);
      default:
        // fallback
        return _m(const SplashScreen(), settings);
    }
  }

  static MaterialPageRoute _m(Widget page, RouteSettings settings) =>
      MaterialPageRoute(builder: (_) => page, settings: settings);
}
