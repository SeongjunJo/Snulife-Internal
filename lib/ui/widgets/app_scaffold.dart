import 'package:flutter/material.dart';
import 'package:snulife_internal/main.dart';
import 'package:snulife_internal/router.dart';

import 'app_bar.dart';

class InternalAppScaffold extends StatelessWidget {
  final String? screenName;
  final Widget child;

  const InternalAppScaffold({
    super.key,
    required this.screenName,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bool isHomeScreen = screenName == '/home';
    final PreferredSizeWidget internalAppBar;
    late final String title;

    if (!isHomeScreen) {
      switch (screenName) {
        case AppRoutePath.settings:
          title = "마이페이지";
        case AppRoutePath.profile:
          title = "프로필 관리";
        default:
          throw Exception("scaffold에서 신규 라우트를 설정해주세요: $screenName");
      }
    }

    isHomeScreen
        ? internalAppBar = HomeScreenAppBar(appBar: AppBar())
        : internalAppBar = SubScreenAppBar(appBar: AppBar(), title: title);

    return Scaffold(
      appBar: internalAppBar,
      body: child,
      backgroundColor: appColors.grey0,
    );
  }
}
