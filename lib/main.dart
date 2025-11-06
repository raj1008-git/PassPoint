import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pass_point/core/utils/dev.log.dart';
import 'package:pass_point/features/visitor/bloc/visitor_bloc.dart';
import 'package:pass_point/features/visitor/bloc/visitor_event.dart';
import 'package:pass_point/features/visitor/bloc/visitor_state.dart';
import 'package:pass_point/firebase_options.dart';

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
                    'Starting PassPoint..',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              );
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'PassPoint skeleton -status: ${state is VisitorReady ? 'Ready' : 'Initial'}',
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    devLog('Check In button pressed on Demo Home');
                  },
                  child: Text('Check-In Demo'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
