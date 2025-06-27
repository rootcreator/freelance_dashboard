import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const FreelancerDashboardApp());
}

return ChangeNotifierProvider(
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
);

