import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snulife_internal/ui/screens/main_screens/my_attendance_screens/late_absence_screen.dart';
import 'package:snulife_internal/ui/screens/main_screens/my_attendance_screens/view_my_attendance_screen.dart';

import '../../../../logics/app_tabs.dart';
import '../../../../logics/providers/select_semester_states.dart';

class MyAttendancePage extends StatelessWidget {
  const MyAttendancePage({
    super.key,
    required this.currentSemester,
    required this.upcomingSemester,
    required this.userInfo,
  });

  final String currentSemester;
  final String? upcomingSemester;
  final Map userInfo;

  @override
  Widget build(BuildContext context) {
    return TabBarView(
        controller: AppTab.myAttendanceTabController,
        children: AppTab.myAttendanceTabs.map((Tab tab) {
          return tab.text! == AppTab.myAttendanceTabs.first.text
              ? LateAbsencePage(
                  currentSemester: currentSemester,
                  upcomingSemester: upcomingSemester,
                )
              : ChangeNotifierProvider(
                  create: (context) => DropdownSelectionStatus(
                      currentSelection: currentSemester),
                  child: ViewMyAttendancePage(
                    userInfo: userInfo,
                    isQSSummary: false, // '내 출결 관리'에서 접근하면 무조건 false
                    currentSemester: currentSemester,
                  ),
                );
        }).toList());
  }
}
