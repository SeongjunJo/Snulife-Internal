import 'package:flutter/material.dart';
import 'package:snulife_internal/ui/screens/main_screens/my_attendance_screens/late_absence_screen.dart';
import 'package:snulife_internal/ui/screens/main_screens/my_attendance_screens/view_my_attendance_screen.dart';

import '../../../../logics/app_tabs.dart';
import '../../../../logics/common_instances.dart';

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
                    if (snapshot.hasData) {
                      return const LateAbsencePage();
                    } else {
                      return Container(color: appColors.grey1);
                    }
                  },
                )
              : FutureBuilder(
                  future: null,
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData) {
                      return const ViewMyAttendancePage();
                    } else {
                      return Container(color: appColors.grey1);
                    }
                  },
                );
        }).toList());
  }
}
