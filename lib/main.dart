// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
//
// import 'core/utils/dev.log.dart';
// // import 'core/utils/dev_log.dart'; // Ensure this path is correct: 'package:pass_point/core/utils/dev.log.dart'
// import 'features/visitor/bloc/visitor_bloc.dart';
// import 'features/visitor/bloc/visitor_event.dart';
// import 'features/visitor/bloc/visitor_state.dart';
// import 'features/visitor/screens/checkin_screen.dart'; // <-- Imported the CheckInScreen
// import 'firebase_options.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   devLog('Flutter binding Initialized');
//   // Make sure your .env file is included in your project assets
//   await dotenv.load(fileName: ".env");
//   devLog('Environment Variables loaded');
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   devLog('Firebase Initialized');
//   runApp(const PassPointApp());
// }
//
// class PassPointApp extends StatelessWidget {
//   const PassPointApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider<VisitorBloc>(
//           create: (context) => VisitorBloc()..add(VisitorInitEvent()),
//         ),
//       ],
//       child: MaterialApp(
//         title: 'PassPoint',
//         // Using a slightly more descriptive title for the app bar
//         home: const HomeScreen(),
//         debugShowCheckedModeBanner: false,
//       ),
//     );
//   }
// }
//
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('PassPoint Demo')), // Using your title
//       body: Center(
//         child: BlocBuilder<VisitorBloc, VisitorState>(
//           builder: (context, state) {
//             if (state is VisitorLoading) {
//               return const Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 12),
//                   Text(
//                     'Starting PassPoint...',
//                     style: TextStyle(fontStyle: FontStyle.italic),
//                   ),
//                 ],
//               );
//             }
//
//             // The default/ready state
//             return Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   'PassPoint skeleton - Status: ${state is VisitorReady ? 'Ready' : 'Initial'}',
//                 ),
//                 const SizedBox(height: 12),
//                 ElevatedButton(
//                   // *** CRITICAL CHANGE: Button is only active when BLoC state is VisitorReady ***
//                   onPressed: state is VisitorReady
//                       ? () {
//                           devLog(
//                             'Check In button pressed, Navigating to CheckInScreen',
//                           );
//                           Navigator.of(context).push(
//                             MaterialPageRoute(
//                               builder: (_) => const CheckInScreen(),
//                             ),
//                           );
//                         }
//                       : null, // Button is disabled if state is not Ready
//                   child: const Text('Check-In Demo'),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/utils/dev.log.dart';
import 'features/admin/screens/admin_login_screen.dart'; // <--- ADMIN IMPORT ADDED
import 'features/visitor/bloc/visitor_bloc.dart';
import 'features/visitor/bloc/visitor_event.dart';
import 'features/visitor/bloc/visitor_state.dart';
import 'features/visitor/screens/checkin_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  devLog('Flutter binding Initialized');
  // Make sure your .env file is included in your project assets
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
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PassPoint Demo')),
      body: Center(
        child: BlocBuilder<VisitorBloc, VisitorState>(
          builder: (context, state) {
            if (state is VisitorLoading) {
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text(
                    'Starting PassPoint...',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              );
            }

            // The default/ready state
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'PassPoint skeleton - Status: ${state is VisitorReady ? 'Ready' : 'Initial'}',
                ),
                const SizedBox(height: 30),

                // 1. Visitor Check-In Button
                ElevatedButton(
                  onPressed: state is VisitorReady
                      ? () {
                          devLog(
                            'Check In button pressed, Navigating to CheckInScreen',
                          );
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CheckInScreen(),
                            ),
                          );
                        }
                      : null,
                  child: const Text('1. Visitor Check-In Kiosk'),
                ),

                const SizedBox(height: 12),

                // 2. Receptionist Dashboard Button (now goes to Login) <--- ADMIN BUTTON ADDED
                ElevatedButton(
                  onPressed: state is VisitorReady
                      ? () {
                          devLog(
                            'Admin button pressed, Navigating to AdminLoginScreen',
                          );
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AdminLoginScreen(),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('2. Admin Dashboard (Login)'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
