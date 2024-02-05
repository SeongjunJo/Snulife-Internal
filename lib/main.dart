import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'logics/providers/login_state.dart';
import 'router.dart';
import 'ui/styles/colors.dart';
import 'ui/styles/fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (context) => LogInState(),
      builder: ((context, child) => const InternalApp()),
    ),
  );
}

class InternalApp extends StatelessWidget {
  const InternalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Spoqa Han Sans Neo',
      ),
      routerConfig: appRouter,
    );
  }
}

AppColors get appColors => AppColors();

AppFonts get appFonts => AppFonts();
