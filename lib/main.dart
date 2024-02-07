import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'logics/firebase_options.dart';
import 'router.dart';
import 'ui/styles/colors.dart';
import 'ui/styles/fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const InternalApp());
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

AppColors get appColors => AppColors();
AppFonts get appFonts => AppFonts();
