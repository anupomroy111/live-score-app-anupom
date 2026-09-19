import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? setupError;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error) {
    setupError = error.toString();
  }
  runApp(LiveScoreApp(setupError: setupError));
}

class LiveScoreApp extends StatelessWidget {
  const LiveScoreApp({super.key, this.setupError});

  final String? setupError;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFBDF75B);
    return MaterialApp(
      title: 'Live Score',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
          surface: const Color(0xFF101D22),
        ),
        scaffoldBackgroundColor: const Color(0xFF091318),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF091318),
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF142329),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: const Color(0xFF0A171B),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A2A30),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: setupError == null
          ? const HomeScreen()
          : Scaffold(
              appBar: AppBar(title: const Text('Live Score')),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.cloud_off_outlined,
                        size: 56,
                        color: accent,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Firebase setup needed',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Check Firebase setup for this platform. See README.md.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      SelectableText(setupError!, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
