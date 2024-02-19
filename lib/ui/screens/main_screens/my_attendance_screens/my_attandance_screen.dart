import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snulife_internal/ui/screens/main_screens/my_attendance_screens/late_absence_screen.dart';
import 'package:snulife_internal/ui/screens/main_screens/my_attendance_screens/view_my_attendance_screen.dart';

import '../../../../logics/app_tabs.dart';
import '../../../../logics/common_instances.dart';
import '../../../../logics/providers/select_semester_states.dart';

class MyAttendancePage extends StatelessWidget {
  const MyAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: memoizer.runOnce(() async {
        return await firestoreReader.getMyAttendanceStatus(
            await firestoreReader.getCurrentAndComingSemester());
      }),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return TabBarView(
              controller: AppTab.myAttendanceTabController,
              children: AppTab.myAttendanceTabs.map((Tab tab) {
                // 별도 Widget으로 분리하면 memoizer로 캐싱할 수 없음

                return tab.text! == '지각/결석'
                    ? LateAbsencePage(upcomingAttendanceStatus: snapshot.data)
                    : ChangeNotifierProvider(
                        create: (context) =>
                            SelectSemesterStatus(currentSemester: '2023-W'),
                        child: const ViewMyAttendancePage(),
                      );
              }).toList());
        } else {
          return Container(color: appColors.grey0);
        }
      },
    );
  }
}
