import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snulife_internal/logics/providers/firebase_states.dart';

import 'logics/firebase_options.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ChangeNotifierProvider(
      create: (context) => FirebaseStates(),
      builder: ((context, child) => const InternalApp()),
    ),
  );
}

class InternalApp extends StatelessWidget {
  const InternalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(useMaterial3: true),
      routerConfig: appRouter,
    );
  }
}
