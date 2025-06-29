import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'auth/login_screen.dart';
import 'dashboard/home_screen.dart';
import 'theme/app_theme.dart';
import 'dashboard/main_screen.dart';
import 'dashboard/splash_screen.dart';
import 'providers/theme_provider.dart'; // make sure this is imported

class FreelancerDashboardApp extends StatefulWidget {
  const FreelancerDashboardApp({super.key});

  @override
  State<FreelancerDashboardApp> createState() => _FreelancerDashboardAppState();
}

class _FreelancerDashboardAppState extends State<FreelancerDashboardApp> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 10), () {
      setState(() {
        _showSplash = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer2<AuthService, ThemeProvider>(
        builder: (context, auth, themeProvider, _) {
          return MaterialApp(
            title: 'Freelancer Dashboard',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            home: _showSplash
                ? const SplashScreen()
                : auth.isLoading
                ? const Scaffold(body: Center(child: CircularProgressIndicator()))
                : auth.user == null
                ? const LoginScreen()
                : const MainScreen(),
          );
        },
      ),
    );
  }
}
