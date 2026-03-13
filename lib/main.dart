// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logbook_app_086/features/logbook/models/log_model.dart';

import 'package:logbook_app_086/features/onboarding/onboarding_view.dart';

void main() async {
  // 1. Pastikan core Flutter sudah siap
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi Hive untuk persistensi lokal LEBIH DULU
  // Ini mencegah Connection Timed Out di perangkat tertentu
  await Hive.initFlutter();
  Hive.registerAdapter(LogModelAdapter());
  
  // Pastikan nama box-nya 'logs' agar sinkron dengan LogController
  await Hive.openBox<LogModel>('logs');

  // 3. Load file .env setelah database lokal siap
  await dotenv.load(fileName: ".env");
  
  // 4. Jalankan aplikasi
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LogBook App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const OnboardingView(),
    );
  }
}