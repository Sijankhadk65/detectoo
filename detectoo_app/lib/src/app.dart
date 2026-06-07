import 'package:flutter/material.dart';

import 'routes.dart';
import 'theme/detectoo_theme.dart';
import 'screens/add_plant_screen.dart';
import 'screens/email_verification_screen.dart';
import 'screens/login_screen.dart';
import 'screens/plant_detail_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/recovery_screen.dart';
import 'screens/splash_screen.dart';
import 'widgets/bottom_nav_bar.dart';

/// Root MaterialApp widget for the Detectoo application.
///
/// Configures the app-wide theme, title, and named routes.
class DetectooApp extends StatelessWidget {
  const DetectooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Detectoo',
      debugShowCheckedModeBanner: false,
      theme: detectooTheme(),
      initialRoute: Routes.splash,
      routes: {
        Routes.splash: (context) => const SplashScreen(),
        Routes.login: (context) => const LoginScreen(),
        Routes.home: (context) => const BottomNavBar(),
        Routes.plantDetail: (context) => const PlantDetailScreen(),
        Routes.recovery: (context) => const RecoveryScreen(),
        Routes.addPlant: (context) => const AddPlantScreen(),
        Routes.signUp: (context) => const SignUpScreen(),
        Routes.emailVerification: (context) => const EmailVerificationScreen(),
      },
    );
  }
}
