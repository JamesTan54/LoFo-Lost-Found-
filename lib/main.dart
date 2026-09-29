import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// Import file course.dart (karena berada di folder lib/ yang sama dengan main.dart)
import 'models/course.dart';

// Import Screen
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
    // 1. Inisialisasi data Course sesuai format tugas
    final course = Course(
      name: 'Pemrograman Web',
      semester: 'Ganjil',
      year: 2026,
    );

    // Opsi: Opsional untuk mengecek output di Console Debug/Terminal
    print(course.displayText); // Hasil: A: Pemrograman Web (Ganjil 2026)

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
          // (Kamu bisa melempar data course ke HomeScreen jika dibutuhkan)
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