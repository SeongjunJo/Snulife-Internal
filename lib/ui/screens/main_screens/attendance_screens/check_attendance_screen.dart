import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snulife_internal/logics/utils/date_util.dart';
import 'package:snulife_internal/ui/widgets/commons/button_widgets.dart';

import '../../../../logics/common_instances.dart';
import '../../../../logics/providers/check_attendance_state.dart';
import '../../../widgets/screen_specified/attendance_widget.dart';

class CheckAttendancePage extends StatelessWidget {
  const CheckAttendancePage({
    super.key,
    required this.isClerk,
    required this.currentSemester,
    required this.userList,
  });

  final bool isClerk;
  final String currentSemester;
  final List<dynamic> userList;

  @override
  Widget build(BuildContext context) {
    final today = DateUtil.getLocalNow();
    final attendanceListener = context.watch<CheckAttendanceState>();
    bool unCompleted = false;

    for (final user in attendanceListener.userAttendanceStatus.keys) {
      if (attendanceListener.userAttendanceStatus[user]!.first == '') {
        unCompleted = true;
        break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: appColors.grey0,
      child: StreamBuilder(
        stream: firestoreReader.getPeopleAttendanceAndClerkStream(
            currentSemester, '0229'),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
            final attendanceStatus =
                snapshot.data!.data() as Map<String, dynamic>;
            bool hasAttendanceConfirmed =
                attendanceStatus['hasAttendanceConfirmed'];

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
                        canModify: isClerk &&
                            !hasAttendanceConfirmed, // 서기이면서 확정하지 않은 상태만 수정 가능
                        name: userList[index],
                        attendanceStatus: attendanceStatus,
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 8);
                    },
                  ),
                ),
                isClerk
                    ? const SizedBox(height: 70)
                    : const SizedBox(), // ListView 때문에 Column으로 못 함
                isClerk
                    ? AppExpandedButton(
                        buttonText: "저장하기",
                        // 확정을 안 했고 수정 사항이 생길 때만 저장 가능
                        onPressed: !hasAttendanceConfirmed &&
                                attendanceListener.hasUpdated
                            ? () {
                                firestoreWriter.saveAttendanceStatus(
                                  currentSemester,
                                  attendanceListener.userAttendanceStatus,
                                  false,
                                );
                                attendanceListener.setHasUpdated(false);
                              }
                            : null,
                      )
                    : const SizedBox(),
                isClerk ? const SizedBox(height: 20) : const SizedBox(),
                isClerk
                    ? AppExpandedButton(
                        buttonText: "확정하기",
                        // 확정을 안 했고, 출석 체크는 전부 했고, 저장도 한 경우만 확정 가능
                        onPressed: !hasAttendanceConfirmed &&
                                !unCompleted &&
                                !attendanceListener.hasUpdated
                            ? () => showDialog(
                                  context: context,
                                  builder: (context) => AttendanceDialog(
                                      currentSemester: currentSemester,
                                      userAttendanceStatus: attendanceListener
                                          .userAttendanceStatus),
                                )
                            : null,
                      )
                    : const SizedBox(),
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

class AttendanceDialog extends StatelessWidget {
  const AttendanceDialog({
    super.key,
    required this.currentSemester,
    required this.userAttendanceStatus,
  });

  final String currentSemester;
  final Map<String, List<dynamic>> userAttendanceStatus;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: appColors.white,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "출석 확정 이후에는\n출결을 변경할 수 없어요.",
              style: appFonts.h3,
            ),
            const SizedBox(height: 8),
            Text(
              "꼭 회의가 완료된 뒤에 확정해주세요.\n확정하시겠어요?",
              style: appFonts.b2.copyWith(color: appColors.grey7),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                AppExpandedButton(
                  buttonText: "아니요",
                  onPressed: () => Navigator.pop(context),
                  // context.pop()은 GoRouter의 pop이어서 홈 화면으로 나가짐
                  isCancelButton: true,
                ),
                const SizedBox(width: 20),
                AppExpandedButton(
                  buttonText: "네",
                  onPressed: () {
                    firestoreWriter.saveAttendanceStatus(
                        currentSemester, userAttendanceStatus, true);
                    firestoreWriter.confirmAttendanceStatus(
                        currentSemester, userAttendanceStatus);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
