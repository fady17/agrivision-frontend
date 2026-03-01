import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'core/app_theme.dart'; 
void main() {
  runApp(
    // Inject AuthService at the top of the tree
    ChangeNotifierProvider(
      create: (_) => AuthService()..checkLoginStatus(),
      child: const AgriVisionApp(),
    ),
  );
}

class AgriVisionApp extends StatelessWidget {
  const AgriVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriVision',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(
      //     seedColor: const Color(0xFF2E7D32),
      //     brightness: Brightness.light,
      //   ),
      //   useMaterial3: true,
      //   textTheme: GoogleFonts.interTextTheme(),
      // ),
      // Use Consumer to listen to auth changes
      home: Consumer<AuthService>(
        builder: (context, auth, _) {
          return auth.isAuthenticated ? const HomeScreen() : const LoginScreen();
        },
      ),
    );
  }
}