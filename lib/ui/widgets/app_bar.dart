import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snulife_internal/main.dart';
import 'package:snulife_internal/router.dart';

class HomeScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeScreenAppBar({
    super.key,
    required this.appBar,
  });

  final AppBar appBar;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 58,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              "assets/images/icon_snulife.png",
              width: 23.77,
              height: 25.46,
            ),
            IconButton(
              icon: Image.asset(
                "assets/images/icon_person.png",
                width: 30,
                height: 30,
              ),
              onPressed: () {
                context.pushNamed(AppRoutePath.settings);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBar.preferredSize.height);
}

class SubScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SubScreenAppBar({
    super.key,
    required this.appBar,
    required this.title,
  });

  final AppBar appBar;
  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 50,
      automaticallyImplyLeading: false,
      centerTitle: true,
      titleSpacing: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            icon: Image.asset(
              "assets/images/icon_left_arrow.png",
              width: 48,
              height: 48,
            ),
            onPressed: () => context.pop(),
          ),
          Text(title, style: appFonts.appBarTitle),
          const SizedBox(width: 48, height: 48),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBar.preferredSize.height);
}
