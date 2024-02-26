import 'package:flutter/material.dart';
import 'package:snulife_internal/ui/screens/main_screens/qs_screens/manage_meeting_screen.dart';
import 'package:snulife_internal/ui/screens/main_screens/qs_screens/qs_screen.dart';

import '../../../../logics/app_tabs.dart';

class ManagementPage extends StatelessWidget {
  const ManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: AppTab.managementTabController,
      children: AppTab.managementTabs.map((Tab tab) {
        return tab.text! == 'QS 관리'
            ? const QSPage()
            : const ManageMeetingPage();
      }).toList(),
    );
  }
}
