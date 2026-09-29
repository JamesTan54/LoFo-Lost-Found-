import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lofo_lost_found/routes/app_routes.dart';
import 'package:lofo_lost_found/screens/home_screen.dart';
import 'package:lofo_lost_found/screens/login_screen.dart';
import 'package:lofo_lost_found/screens/register_screen.dart';
import 'package:lofo_lost_found/screens/add_item_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lost & Found',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFC87038),
      ),
      // Map rute didefinisikan langsung menggunakan konstanta AppRoutes
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.addItem: (context) => const AddItemScreen(),
      },
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFFC87038)),
              ),
            );
          }

          if (snapshot.hasData) {
            return const HomeScreen();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}