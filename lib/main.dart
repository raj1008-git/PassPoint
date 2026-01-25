import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/dev.log.dart';
import 'features/admin/screens/admin_dashboard_screen.dart';
import 'features/admin/screens/receptionist_microsoft_login_screen.dart';
import 'features/splash/screens/role_selection_screen.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/staff/screens/staff_dashboard_screen.dart';
import 'features/staff/screens/staff_microsoft_login_screen.dart';
import 'features/staff/screens/staff_registration_screen.dart';
import 'features/visitor/bloc/visitor_bloc.dart';
import 'features/visitor/bloc/visitor_event.dart';
import 'features/visitor/screens/visitor_welcome_screen.dart';
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
    return MultiBlocProvider(
      providers: [
        BlocProvider<VisitorBloc>(
          create: (context) => VisitorBloc()..add(VisitorInitEvent()),
        ),
      ],
      child: MaterialApp(
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
          '/home': (context) => const VisitorWelcomeScreen(),

          // NEW - Microsoft Auth Routes
          '/receptionist-login': (context) =>
              const ReceptionistMicrosoftLoginScreen(),
          '/staff-login': (context) => const StaffMicrosoftLoginScreen(),
          '/staff-registration': (context) => const StaffRegistrationScreen(),

          // Dashboard Routes
          '/admin-dashboard': (context) => const AdminDashboardScreen(),
          '/staff-dashboard': (context) => const StaffDashboardScreen(),
        },
      ),
    );
  }
}
