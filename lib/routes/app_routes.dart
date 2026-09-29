import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/add_item_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String addItem = '/add-item';

  static Map get routes => {
        login: (BuildContext context) => const LoginScreen(),
        register: (BuildContext context) => const RegisterScreen(),
        home: (BuildContext context) => const HomeScreen(),
        addItem: (BuildContext context) => const AddItemScreen(),
      };
}