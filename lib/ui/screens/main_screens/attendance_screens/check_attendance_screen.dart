import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snulife_internal/logics/utils/date_util.dart';
import 'package:snulife_internal/ui/widgets/commons/button_widgets.dart';

import '../../../../logics/common_instances.dart';
import '../../../widgets/screen_specified/attendance_widget.dart';

class CheckAttendancePage extends StatelessWidget {
  const CheckAttendancePage({super.key, required this.userList});

  final List<dynamic> userList;

  @override
  Widget build(BuildContext context) {
    final today = DateUtil.getLocalNow();
    Stream<DocumentSnapshot> usersStream =
        firestoreReader.getAttendanceStatus('2023-4', '0215');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: appColors.grey0,
      child: StreamBuilder(
        stream: usersStream,
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
            return ListView(
              children: [
                const SizedBox(height: 32),
                Text(
                  "${today.month}월 ${today.day}일자 회의\n출석체크를 해주세요.",
                  style: appFonts.h1,
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: ListView.separated(
                    // 전체 위젯이 한번에 빌드되지만, 인원수가 많지 않고 index는 필요하므로 builder 사용
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: userList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return AttendanceListItem(
                        name: userList[index],
                        attendanceStatus:
                            snapshot.data!.data() as Map<String, dynamic>,
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 8);
                    },
                  ),
                ),
                const SizedBox(height: 70),
                AppExpandedButton(
                  buttonText: "돌아가기",
                  onPressed: () => context.pop(),
                ),
                const SizedBox(height: 40),
              ],
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
