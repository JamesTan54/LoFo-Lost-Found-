import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'providers/theme_provider.dart';
import 'routes/app_routes.dart';
import 'services/notification_service.dart';
import 'services/app_logger.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_item_screen.dart';
import 'screens/my_reports_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    AppLogger.error(
      'FLUTTER_UI',
      details.exceptionAsString(),
      details.exception,
      details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    AppLogger.error('ASYNC_RUNTIME', 'Uncaught runtime error', error, stack);
    return true;
  };

  AppLogger.info('MAIN', 'Aplikasi LoFo mulai dijalankan...');

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLogger.info('FIREBASE', 'Firebase berhasil diinisialisasi');
  } catch (e, stack) {
    AppLogger.warning('FIREBASE', 'Firebase dilewati / gagal init: $e');
    debugPrint('$stack');
  }

  if (!kIsWeb) {
    await NotificationService.init();
    AppLogger.info('NOTIFICATION', 'NotificationService aktif');
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'LoFo App',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFAF7F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC87038),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAF7F5),
          foregroundColor: Color(0xFF2D241E),
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF141414),
        cardColor: const Color(0xFF1F1F1F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD9824B),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF141414),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: Firebase.apps.isEmpty
          ? const LoginScreen()
          : StreamBuilder(
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
                  AppLogger.info(
                    'AUTH',
                    'User aktif terdeteksi: ${snapshot.data?.email ?? snapshot.data?.uid}',
                  );
                  return const HomeScreen();
                }

                AppLogger.info('AUTH', 'Belum ada sesi login, membuka LoginScreen');
                return const LoginScreen();
              },
            ),
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.addItem: (context) => const AddItemScreen(),
        AppRoutes.myReports: (context) => const MyReportsScreen(),
      },
    );
  }
}