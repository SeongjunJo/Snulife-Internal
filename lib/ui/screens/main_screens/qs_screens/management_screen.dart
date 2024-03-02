import 'package:flutter/material.dart';
import 'package:snulife_internal/ui/screens/main_screens/qs_screens/manage_meeting_screen.dart';
import 'package:snulife_internal/ui/screens/main_screens/qs_screens/qs_screen.dart';

import '../../../../logics/app_tabs.dart';
import '../../../../logics/common_instances.dart';

class ManagementPage extends StatelessWidget {
  const ManagementPage({super.key, required this.currentSemester});

  final String currentSemester;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firestoreReader.getUserList(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        final userList = snapshot.data;

        if (snapshot.hasData) {
          return TabBarView(
            controller: AppTab.managementTabController,
            children: AppTab.managementTabs.map((Tab tab) {
              return tab.text! == '회의 관리'
                  ? ManageMeetingPage(currentSemester: currentSemester)
                  : QSPage(
                      currentSemester: currentSemester,
                      userList: userList,
                    );
            }).toList(),
          );
        } else {
          return Container(color: appColors.grey0);
        }
      },
    );
  }
}
