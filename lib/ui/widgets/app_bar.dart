import 'package:flutter/material.dart';
import 'package:snulife_internal/main.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              "assets/images/icon_snulife.png",
              width: 23.77,
              height: 25.46,
            ),
            Image.asset(
              "assets/images/icon_person.png",
              width: 30,
              height: 30,
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
      leading: IconButton(
        icon: Image.asset(
          "assets/images/icon_left_arrow.png",
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(title, style: appFonts.tm),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBar.preferredSize.height);
}
