import 'package:go_router/go_router.dart';
import 'package:snulife_internal/ui/screens/home_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      // TODO 로그인 페이지로 변경
      builder: (context, state) => const HomePage(),
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
