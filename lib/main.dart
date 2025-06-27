import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'theme_provider.dart'; // assuming this is where ThemeProvider is
import 'main_screen.dart';   // assuming this is your main screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            themeMode: provider.themeMode,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            home: const MainScreen(),
          );
        },
      ),
    ),
  );
}