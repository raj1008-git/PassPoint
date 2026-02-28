import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/dev.log.dart';
import 'features/admin/screens/receptionist_dashboard_screen.dart'; // Your existing
import 'features/admin/screens/receptionist_login_screen.dart';
import 'features/splash/screens/role_selection_screen.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/staff/screens/staff_auth_screen.dart';
import 'features/staff/screens/staff_dashboard_screen.dart'; // Your existing
import 'features/visitor/screens/visitor_welcome_screen.dart'; // Your existing
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  devLog('Flutter binding Initialized');

  await dotenv.load(fileName: ".env");
  devLog('Environment Variables loaded');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  devLog('Firebase Initialized');

  runApp(const PassPointApp());
}

class PassPointApp extends StatelessWidget {
  const PassPointApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PassPoint',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppTheme.primaryRed,
        scaffoldBackgroundColor: AppTheme.background,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.primaryRed,
          primary: AppTheme.primaryRed,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/role-selection': (context) => const RoleSelectionScreen(),
        '/receptionist-login': (context) => const ReceptionistLoginScreen(),
        '/staff-auth': (context) => const StaffAuthScreen(),
        '/home': (context) => const VisitorWelcomeScreen(),
        '/admin-dashboard': (context) => const ReceptionistDashboardScreen(),
        '/staff-dashboard': (context) => const StaffDashboardScreen(),
      },
    );
  }
}
