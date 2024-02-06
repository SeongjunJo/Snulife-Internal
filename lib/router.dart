import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:snulife_internal/ui/screens/home_screen.dart';
import 'package:snulife_internal/ui/screens/login_screen.dart';
import 'package:snulife_internal/ui/screens/profile_screen.dart';
import 'package:snulife_internal/ui/screens/setting_screen.dart';
import 'package:snulife_internal/ui/widgets/app_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: AppRoutePath.login,
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
          path: AppRoutePath.home,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: AppRoutePath.settings,
          builder: (context, state) => const SettingPage(),
          routes: [
            GoRoute(
              path: 'profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    )
  ],
);

class AppRoutePath {
  static const home = '/home';
  static const login = '/login';
  static const settings = '/settings';
  static const profile = '/settings/profile';
}
