import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snulife_internal/ui/screens/main_screens/my_attendance_screens/late_absence_screen.dart';
import 'package:snulife_internal/ui/screens/main_screens/my_attendance_screens/view_my_attendance_screen.dart';

import '../../../../logics/app_tabs.dart';
import '../../../../logics/common_instances.dart';
import '../../../../logics/providers/select_semester_states.dart';
import '../../../../logics/utils/string_util.dart';

class MyAttendancePage extends StatelessWidget {
  const MyAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return TabBarView(
        controller: AppTab.myAttendanceTabController,
        children: AppTab.myAttendanceTabs.map((Tab tab) {
          // 별도 Widget으로 분리하면 memoizer로 캐싱할 수 없음

          return tab.text! == '지각/결석'
              ? FutureBuilder(
                  future: null,
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    // TODO FUTURE 정해지면 느낌표 제거
                    if (!snapshot.hasData) {
                      return const LateAbsencePage(myAttendanceStatus: []);
                    } else {
                      return Container(color: appColors.grey0);
                    }
                  },
                )
              : FutureBuilder(
                  future: memoizer.runOnce(
                      () async => await StringUtil.getCurrentSemester()),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData) {
                      return ChangeNotifierProvider(
                          create: (context) => SelectSemesterStatus(
                              currentSemester: snapshot.data),
                          child: const ViewMyAttendancePage());
                    } else {
                      return Container(color: appColors.grey0);
                    }
                  },
                );
        }).toList());
  }
}
