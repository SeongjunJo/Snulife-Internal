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
  });

  final String currentSemester;
  final String? upcomingSemester;

  @override
  Widget build(BuildContext context) {
    return TabBarView(
        controller: AppTab.myAttendanceTabController,
        children: AppTab.myAttendanceTabs.map((Tab tab) {
          // 별도 Widget으로 분리하면 memoizer로 캐싱할 수 없음
          return tab.text! == '지각/결석'
              ? LateAbsencePage(
                  currentSemester: currentSemester,
                  upcomingSemester: upcomingSemester,
                )
              : ChangeNotifierProvider(
                  create: (context) =>
                      SelectSemesterStatus(currentSemester: currentSemester),
                  child: ViewMyAttendancePage(
                    isManager: false, // '내 출결 관리'에서 접근하면 무조건 false
                    currentSemester: currentSemester,
                  ),
                );
        }).toList());
  }
}
