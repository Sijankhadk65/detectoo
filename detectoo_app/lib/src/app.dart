import 'package:flutter/material.dart';

import 'routes.dart';
import 'screens/login_screen.dart';
import 'screens/plant_detail_screen.dart';
import 'screens/recovery_screen.dart';
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: Routes.login,
      routes: {
        Routes.login: (context) => const LoginScreen(),
        Routes.home: (context) => const BottomNavBar(),
        Routes.plantDetail: (context) => const PlantDetailScreen(),
        Routes.recovery: (context) => const RecoveryScreen(),
      },
    );
  }
}
