// main.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logbook_app_086/features/logbook/models/log_model.dart';

import 'package:logbook_app_086/features/onboarding/onboarding_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive untuk persistensi lokal
  await Hive.initFlutter();
  Hive.registerAdapter(LogModelAdapter());
  await Hive.openBox<LogModel>('logs');

  await dotenv.load(fileName: ".env");
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
