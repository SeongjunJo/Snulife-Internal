import 'package:go_router/go_router.dart';
import 'package:snulife_internal/ui/screens/home_screen.dart';
import 'package:snulife_internal/ui/screens/login_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LogInPage(),
      routes: [
        GoRoute(
          path: 'home',
          builder: (context, state) {
            return const HomePage();
          },
        ),
      ],
    ),
  ],
);
