import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'auth/login_screen.dart';
import 'dashboard/home_screen.dart';
import 'theme/app_theme.dart';
import 'dashboard/main_screen.dart';


class FreelancerDashboardApp extends StatelessWidget {
  const FreelancerDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthService>(
      create: (_) => AuthService(),
      child: Consumer<AuthService>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'Freelancer Dashboard',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: auth.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: auth.isLoading
                ? const Scaffold(body: Center(child: CircularProgressIndicator()))
                : auth.user == null
                    ? const LoginScreen()
                    //: const HomeScreen(),
                    : const MainScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
