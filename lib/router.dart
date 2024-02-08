import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snulife_internal/ui/screens/main_screens/home_screen.dart';
import 'package:snulife_internal/ui/screens/setting_screens/profile_screen.dart';
import 'package:snulife_internal/ui/screens/setting_screens/setting_screen.dart';
import 'package:snulife_internal/ui/screens/sign_screens/confirm_password_reset_screen.dart';
import 'package:snulife_internal/ui/screens/sign_screens/forgotten_password_screen.dart';
import 'package:snulife_internal/ui/screens/sign_screens/login_screen.dart';
import 'package:snulife_internal/ui/widgets/commons/app_scaffolds.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _signShellNavigatorKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _mainShellNavigatorKey =
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
        ShellRoute(
          navigatorKey: _signShellNavigatorKey,
          builder: (context, state, child) => SignScreensScaffold(child: child),
          routes: [
            GoRoute(
              name: AppRoutePath.forgottenPassword,
              path: 'forgottenPassword',
              pageBuilder: (context, state) => const MaterialPage(
                child: ForgottenPasswordPage(),
                fullscreenDialog: true,
              ),
            ),
            GoRoute(
              name: AppRoutePath.confirmPasswordReset,
              path: 'confirmPasswordReset',
              pageBuilder: (context, state) => const MaterialPage(
                child: ConfirmPasswordResetPage(),
                fullscreenDialog: true,
              ),
            ),
          ],
        ),
      ],
    ),
    ShellRoute(
      navigatorKey: _mainShellNavigatorKey,
      builder: (context, state, child) =>
          InternalAppScaffold(screenPath: state.fullPath, child: child),
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
  static const confirmPasswordReset = '/login/confirmPasswordReset';

  static const home = '/home';

  static const settings = '/settings';
  static const profile = '/settings/profile';
}
