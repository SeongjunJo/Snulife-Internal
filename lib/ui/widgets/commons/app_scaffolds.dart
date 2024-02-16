import 'package:flutter/material.dart';
import 'package:snulife_internal/router.dart';

import '../../../logics/app_tabs.dart';
import '../../../logics/common_instances.dart';
import 'app_bars.dart';

class InternalAppScaffold extends StatefulWidget {
  const InternalAppScaffold({
    super.key,
    required this.screenPath,
    required this.child,
  });

  final String? screenPath;
  final Widget child;

  @override
  State<InternalAppScaffold> createState() => _InternalAppScaffoldState();
}

class _InternalAppScaffoldState extends State<InternalAppScaffold>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    AppTab.attendanceTabController =
        TabController(length: AppTab.attendanceTabs.length, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    AppTab.attendanceTabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isHomeScreen = widget.screenPath == '/home';
    final PreferredSizeWidget internalAppBar;
    late final String title;
    late final bool isTabView;

    if (!isHomeScreen) {
      switch (widget.screenPath) {
        case AppRoutePath.settings:
          title = "마이페이지";
          isTabView = false;
        case AppRoutePath.profile:
          title = "프로필 관리";
          isTabView = false;
        case AppRoutePath.attendance:
          title = "출결";
          isTabView = true;
        default:
          throw Exception("scaffold에서 신규 라우트를 설정해주세요: ${widget.screenPath}");
      }
    }

    isHomeScreen
        ? internalAppBar = HomeScreenAppBar(appBar: AppBar())
        : internalAppBar = SubScreenAppBar(
            appBar: AppBar(),
            title: title,
            isTabView: isTabView,
          );

    return Scaffold(
      appBar: internalAppBar,
      body: widget.child,
      backgroundColor: appColors.grey0,
    );
  }
}

class SignScreensScaffold extends StatelessWidget {
  const SignScreensScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("비밀번호 초기화"),
        toolbarHeight: 50,
        titleSpacing: 0,
        backgroundColor: appColors.white,
      ),
      body: child,
      backgroundColor: appColors.white,
    );
  }
}
