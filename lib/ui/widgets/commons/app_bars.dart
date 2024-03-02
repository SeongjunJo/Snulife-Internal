import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snulife_internal/router.dart';

import '../../../logics/app_tabs.dart';
import '../../../logics/common_instances.dart';

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
              onPressed: () => context.pushNamed(AppRoutePath.settings),
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
    required this.isTabView,
  });

  final AppBar appBar;
  final String title;
  final bool isTabView;

  @override
  Widget build(BuildContext context) {
    late TabController tabController;
    late List<Widget> appTabs;

    switch (title) {
      case "출결":
        tabController = AppTab.attendanceTabController;
        appTabs = AppTab.attendanceTabs;
      case "내 출결 관리":
        tabController = AppTab.myAttendanceTabController;
        appTabs = AppTab.myAttendanceTabs;
      case "운영":
        tabController = AppTab.managementTabController;
        appTabs = AppTab.managementTabs;
    }

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
              "assets/images/icon_arrow_left.png",
              width: 48,
              height: 48,
            ),
            onPressed: () => context.pop(),
          ),
          Text(title, style: appFonts.t4.copyWith(color: appColors.grey7)),
          const SizedBox(width: 48, height: 48),
        ],
      ),
      bottom: isTabView
          ? TabBar(
              controller: tabController,
              tabs: appTabs,
              indicator: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: appColors.slBlue, width: 2),
                ),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: appColors.grey3,
              labelColor: appColors.grey9,
              unselectedLabelColor: appColors.grey5,
              labelStyle: appFonts.b1,
              unselectedLabelStyle: appFonts.b1,
            )
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(isTabView ? 100 : 50);
}
