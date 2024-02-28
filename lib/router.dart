import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:snulife_internal/logics/providers/firebase_states.dart';
import 'package:snulife_internal/ui/screens/main_screens/attendance_screens/attandance_screen.dart';
import 'package:snulife_internal/ui/screens/main_screens/home_screen.dart';
import 'package:snulife_internal/ui/screens/main_screens/my_attendance_screens/my_attandance_screen.dart';
import 'package:snulife_internal/ui/screens/main_screens/qs_screens/management_screen.dart';
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
          builder: (context, state) => Consumer<FirebaseStates>(
            builder: (context, value, _) => HomePage(
              isManager: value.isManager,
              userInfo: value.userInfo!,
              clerk: value.clerk,
            ),
          ),
          routes: [
            GoRoute(
              name: AppRoutePath.attendance,
              path: 'attendance',
              builder: (context, state) => Consumer<FirebaseStates>(
                builder: (context, value, _) => AttendancePage(
                  currentSemester: value.currentSemester,
                  clerk: value.clerk,
                  isLeader: value.isLeader,
                ),
              ),
            ),
            GoRoute(
              name: AppRoutePath.myAttendance,
              path: 'myAttendance',
              builder: (context, state) => Consumer<FirebaseStates>(
                builder: (context, value, _) => MyAttendancePage(
                  currentSemester: value.currentSemester,
                  upcomingSemester: value.upcomingSemester,
                ),
              ),
            ),
            GoRoute(
              name: AppRoutePath.management,
              path: 'management',
              builder: (context, state) => Consumer<FirebaseStates>(
                builder: (context, value, _) => ManagementPage(
                  currentSemester: value.currentSemester,
                ),
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
  static const management = '/home/management';

  static const settings = '/settings';
  static const profile = '/settings/profile';
}
