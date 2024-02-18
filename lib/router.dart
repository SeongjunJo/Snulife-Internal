import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:snulife_internal/ui/screens/main_screens/attendance_screens/attandance_screen.dart';
import 'package:snulife_internal/ui/screens/main_screens/home_screen.dart';
import 'package:snulife_internal/ui/screens/main_screens/my_attendance_screens/my_attandance_screen.dart';
import 'package:snulife_internal/ui/screens/setting_screens/profile_screen.dart';
import 'package:snulife_internal/ui/screens/setting_screens/setting_screen.dart';
import 'package:snulife_internal/ui/screens/sign_screens/confirm_password_reset_screen.dart';
import 'package:snulife_internal/ui/screens/sign_screens/forgotten_password_screen.dart';
import 'package:snulife_internal/ui/screens/sign_screens/login_screen.dart';
import 'package:snulife_internal/ui/widgets/commons/app_scaffolds.dart';

import 'logics/common_instances.dart';
import 'logics/providers/select_semester_states.dart';
import 'logics/utils/string_util.dart';

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
          routes: [
            GoRoute(
              name: AppRoutePath.attendance,
              path: 'attendance',
              builder: (context, state) => const AttendancePage(),
            ),
            GoRoute(
              name: AppRoutePath.myAttendance,
              path: 'myAttendance',
              builder: (context, state) => FutureBuilder(
                future: memoizer
                    .runOnce(() async => await StringUtil.getCurrentSemester()),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    return ChangeNotifierProvider(
                        create: (context) => SelectSemesterStatus(
                            currentSemester: snapshot.data),
                        child: const MyAttendancePage());
                  } else {
                    return Container(color: appColors.grey0);
                  }
                },
              ),
            ),
          ],
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
  static const attendance = '/home/attendance';
  static const myAttendance = '/home/myAttendance';

  static const settings = '/settings';
  static const profile = '/settings/profile';
}
