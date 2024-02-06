import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:snulife_internal/ui/screens/home_screen.dart';
import 'package:snulife_internal/ui/screens/login_screen.dart';
import 'package:snulife_internal/ui/widgets/app_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LogInPage(),
      routes: const [],
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return InternalAppScaffold(
          screenName: state.fullPath,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),
      ],
    )
  ],
);
