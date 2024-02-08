import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:snulife_internal/ui/screens/main_screens/home_screen.dart';
import 'package:snulife_internal/ui/screens/setting_screens/profile_screen.dart';
import 'package:snulife_internal/ui/screens/setting_screens/setting_screen.dart';
import 'package:snulife_internal/ui/screens/sign_screens/forgotten_password_screen.dart';
import 'package:snulife_internal/ui/screens/sign_screens/login_screen.dart';
import 'package:snulife_internal/ui/widgets/commons/app_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutePath.login,
  routes: [
    GoRoute(
      name: AppRoutePath.login,
      path: AppRoutePath.login,
      builder: (context, state) => const LogInPage(),
      routes: [
        GoRoute(
          name: AppRoutePath.forgottenPassword,
          path: 'forgottenPassword',
          pageBuilder: (context, state) => const CupertinoPage(
            child: ForgottenPasswordPage(),
            fullscreenDialog: true,
          ),
        )
      ],
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return InternalAppScaffold(
          screenPath: state.fullPath,
          child: child,
        );
      },
      routes: [
        GoRoute(
          name: AppRoutePath.home,
          path: AppRoutePath.home,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          name: AppRoutePath.settings,
          path: AppRoutePath.settings,
          pageBuilder: (context, state) =>
              const CupertinoPage(child: SettingPage()),
          routes: [
            GoRoute(
              name: AppRoutePath.profile,
              path: 'profile',
              pageBuilder: (context, state) =>
                  const CupertinoPage(child: ProfilePage()),
            ),
          ],
        ),
      ],
    )
  ],
);

class AppRoutePath {
  static const login = '/login';
  static const forgottenPassword = '/login/forgottenPassword';

  static const home = '/home';

  static const settings = '/settings';
  static const profile = '/settings/profile';
}
