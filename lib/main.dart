// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sampah/pages/article_screen.dart';
import 'package:sampah/pages/history_screen.dart';
import 'package:sampah/pages/schedule_screen.dart';
import 'package:sampah/pages/waste_input_screen.dart';
import 'firebase_options.dart';
import 'package:sampah/pages/splash_screen.dart';
import 'package:sampah/pages/forgot_password_screen.dart';
import 'package:sampah/pages/register_screen.dart';
import 'package:sampah/pages/login_screen.dart';
import 'package:sampah/pages/dashboard_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Waste Management',
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/schedulePickup': (context) => const ScheduleScreen(),
        '/wasteInput': (context) => const WasteInputScreen(
              userId: '',
              userName: '',
            ),
        '/articles': (context) => ArticleScreen(),
        '/history': (context) =>
            const HistoryScreen(userId: ''), // Ganti userId dengan data yang sesuai

        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/dashboard': (context) => const DashboardScreen(
              userName: '',
              userId: '',
            ),
      },
    );
  }
}
