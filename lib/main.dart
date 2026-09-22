import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'firebase_options.dart';

// Import Screen (Sesuaikan folder/path di proyek Anda jika berbeda)
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

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
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Indikator loading saat autentikasi diperiksa
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFFC87038)),
              ),
            );
          }

          // Jika sudah login -> Tampilkan HomeScreen
          if (snapshot.hasData) {
            return const HomeScreen();
          }

          // Jika belum/setelah logout -> Tampilkan LoginScreen
          return const LoginScreen();
        },
      ),
    );
  }
}