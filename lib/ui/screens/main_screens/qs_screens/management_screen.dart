import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snulife_internal/ui/screens/main_screens/qs_screens/manage_meeting_screen.dart';
import 'package:snulife_internal/ui/screens/main_screens/qs_screens/qs_screen.dart';

import '../../../../logics/app_tabs.dart';
import '../../../../logics/common_instances.dart';
import '../../../../logics/providers/select_semester_states.dart';

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
          final lastTwoHalf = _getLastTwoHalf(currentSemester);

          return TabBarView(
            controller: AppTab.managementTabController,
            children: AppTab.managementTabs.map((Tab tab) {
              return tab.text! == AppTab.managementTabs.first.text
                  ? ManageMeetingPage(currentSemester: currentSemester)
                  : ChangeNotifierProvider(
                      create: (context) => DropdownSelectionStatus(
                          currentSelection: lastTwoHalf.last),
                      child: QSPage(
                        userList: userList,
                        lastTwoHalf: lastTwoHalf,
                      ));
            }).toList(),
          );
        } else {
          return Container(color: appColors.grey0);
        }
      },
    );
  }
}

List<String> _getLastTwoHalf(String semester) {
  final currentYear = int.parse(semester.split('-')[0]);
  final currentSemester = semester.split('-')[1];
  late final List<String> lastTwoHalf;

  switch (currentSemester) {
    case '1':
      lastTwoHalf = ['${currentYear - 1}년 상반기', '${currentYear - 1}년 하반기'];
    case 'S' || '2':
      lastTwoHalf = ['${currentYear - 1}년 하반기', '$currentYear년 상반기'];
    case 'W':
      lastTwoHalf = ['$currentYear년 상반기', '$currentYear년 하반기'];
  }
  return lastTwoHalf;
}
