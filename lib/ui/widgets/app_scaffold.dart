import 'package:flutter/material.dart';

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
        case '/settings':
          title = "마이페이지";
        case '/profile':
          title = "프로필 관리";
        default:
          throw Exception("Unspecified Route: $screenName");
      }
    }

    isHomeScreen
        ? internalAppBar = HomeScreenAppBar(appBar: AppBar())
        : internalAppBar = SubScreenAppBar(appBar: AppBar(), title: title);

    return Scaffold(
      appBar: internalAppBar,
      body: child,
    );
  }
}
