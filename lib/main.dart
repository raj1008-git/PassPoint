// lib/main.dart
//
// CHANGES FROM ORIGINAL (additive only):
//   + 7 new route entries for event management feature
//   + 5 new screen imports
//
// ZERO changes to existing app config, theme, init sequence, or routes.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/dev.log.dart';
import 'data/local/isar_service.dart';
import 'features/admin/screens/admin_dashboard_screen.dart';
import 'features/admin/screens/receptionist_login_screen.dart';
import 'features/splash/screens/role_selection_screen.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/staff/screens/staff_auth_screen.dart';
import 'features/staff/screens/staff_dashboard_screen.dart';
import 'features/visitor/screens/visitor_welcome_screen.dart';
import 'firebase_options.dart';

// ── NEW imports ───────────────────────────────────────────────────────────────
import 'features/events/screens/event_manager_login_screen.dart';
import 'features/events/screens/event_dashboard_screen.dart';
import 'features/events/screens/event_create_screen.dart';
import 'features/events/screens/event_detail_screen.dart';
import 'features/events/screens/gift_inventory_screen.dart';
import 'features/events/screens/add_invitee_screen.dart';
import 'features/events/screens/event_scanner_screen.dart';
import 'features/events/screens/gift_confirmation_screen.dart';
import 'features/events/screens/event_export_screen.dart';
// ─────────────────────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  devLog('Flutter binding Initialized');

  await dotenv.load(fileName: ".env");
  devLog('Environment Variables loaded');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  devLog('Firebase Initialized');

  await IsarService.init();
  ServiceLocator.staffSync.syncIfNeeded();

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
        // ── Existing routes — UNCHANGED ──────────────────────────────────────
        '/': (context) => const SplashScreen(),
        '/role-selection': (context) => const RoleSelectionScreen(),
        '/receptionist-login': (context) => const ReceptionistLoginScreen(),
        '/staff-auth': (context) => const StaffAuthScreen(),
        '/home': (context) => const VisitorWelcomeScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
        '/staff-dashboard': (context) => const StaffDashboardScreen(),

        // ── NEW routes — event management feature ────────────────────────────
        '/event-manager-login': (context) =>
        const EventManagerLoginScreen(),
        '/event-dashboard': (context) => const EventDashboardScreen(),
        '/event-create': (context) => const EventCreateScreen(),
        '/event-detail': (context) => const EventDetailScreen(),
        '/gift-inventory': (context) => const GiftInventoryScreen(),
        '/add-invitee': (context) => const AddInviteeScreen(),
        '/event-scanner': (context) => const EventScannerScreen(),
        '/gift-confirmation': (context) => const GiftConfirmationScreen(),
        '/event-export': (context) => const EventExportScreen(),
        // ─────────────────────────────────────────────────────────────────────
      },
    );
  }
}