import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase is optional for MVP runtime; local storage remains primary.
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Ignore init failures when Firebase is not configured.
  }

  await DatabaseService.instance.initialize();
  runApp(const SmartClassCheckinApp());
}

class SmartClassCheckinApp extends StatelessWidget {
  const SmartClassCheckinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Class Check-in',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0E7490)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
