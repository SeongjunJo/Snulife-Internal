import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snulife_internal/logics/utils/string_util.dart';

import '../../../../../logics/common_instances.dart';
import '../../../../widgets/commons/button_widgets.dart';
import '../../../../widgets/commons/modal_widgets.dart';
import '../../../../widgets/commons/snackbar_widget.dart';
import '../../../../widgets/screen_specified/my_attendance_widget.dart';

class SetRestOrTeemMeetingPage extends StatefulWidget {
  const SetRestOrTeemMeetingPage({
    super.key,
    required this.currentSemester,
  });

  final String currentSemester;

  @override
  State<SetRestOrTeemMeetingPage> createState() =>
      SetRestOrTeemMeetingPageState();
}

class SetRestOrTeemMeetingPageState extends State<SetRestOrTeemMeetingPage> {
  final List<int> selectedIndexes = [];
  final List<String> selectedDates = [];
  final ValueNotifier<bool?> _isRest =
      ValueNotifier(null); // null이면 선택 안 함, true면 휴회, false면 팀별 회의

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        firebaseInstance.db.collection('information').doc('meetingTime').get(),
        firebaseInstance.db
            .collection('attendances')
            .doc(widget.currentSemester)
            .collection('dates')
            .get(),
      ]),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          final today =
              StringUtil.convertDateTimeToString(DateTime.now(), true);
          final List<String> meetingRestDates =
              snapshot.data[0].data()['rest'].cast<String>();
          final List<String> teamMeetingDates =
              snapshot.data[0].data()['teamMeeting'].cast<String>();
          final List allMeetingDatesDocs = snapshot.data[1].docs;
          final List<String> allMeetingDates = [];
          late final int originalMeetingDateCount;
          late final int adjustedMeetingDateCount;
          late final int offset =
              originalMeetingDateCount - adjustedMeetingDateCount;

          for (final doc in allMeetingDatesDocs) {
            allMeetingDates.add(doc.id);
          }
          originalMeetingDateCount = allMeetingDates.length;
          allMeetingDates
              .removeWhere((element) => int.parse(element) < int.parse(today));
          adjustedMeetingDateCount = allMeetingDates.length;

          return Expanded(
            child: ListView.separated(
              itemCount: allMeetingDates.length + 5,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Text('휴회/팀별 회의 일로 변경할\n정기 회의 일자를 선택해주세요.',
                      style: appFonts.h1);
                } else if (index == 1) {
                  return const SizedBox(height: 16);
                } else if (index == allMeetingDates.length + 2) {
                  return const SizedBox(height: 29);
                } else if (index == allMeetingDates.length + 4) {
                  return const SizedBox(height: 16);
                } else if (index == allMeetingDates.length + 3) {
                  return AppExpandedButton(
                    buttonText: '변경',
                    onPressed: selectedIndexes.isNotEmpty
                        ? () {
                            _isRest.value = null;
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return ValueListenableBuilder<bool?>(
                                  valueListenable: _isRest,
                                  builder: (context, bool? value, _) {
                                    return SelectOnlyBottomModal(
                                        height: 290,
                                        title: '변경 유형을 선택해주세요.',
                                        tapTexts: const ['휴회', '팀별 회의'],
                                        onTapsPressed: [
                                          () => _isRest.value = true,
                                          () => _isRest.value = false,
                                        ],
                                        onBtnPressed: _isRest.value != null
                                            ? () => _onPressed(_isRest.value!,
                                                widget.currentSemester)
                                            : null);
                                  },
                                );
                              },
                            );
                          }
                        : null,
                  );
                } else {
                  final date = allMeetingDates[index - 2].toString();
                  final bool isRestDate = meetingRestDates.contains(date);
                  final bool isTeamMeetingDate =
                      teamMeetingDates.contains(date);
                  String status = '';
                  if (isRestDate) status = '휴회';
                  if (isTeamMeetingDate) status = '팀별 회의';

                  return GestureDetector(
                    onTap: !(isRestDate || isTeamMeetingDate)
                        ? () {
                            setState(() {
                              if (selectedIndexes.contains(index - 2)) {
                                selectedIndexes.remove(index - 2);
                                selectedDates.remove(date);
                              } else {
                                selectedIndexes.add(index - 2);
                                selectedDates.add(date);
                              }
                            });
                          }
                        : null,
                    child: MyAttendanceListItem(
                      week: index + offset - 1,
                      date: date,
                      isSelected: selectedIndexes.contains(index - 2),
                      status: status,
                    ),
                  );
                }
              },
              separatorBuilder: (context, index) {
                return const SizedBox(height: 8);
              },
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  _onPressed(bool isRest, String semester) async {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) => ConfirmDialog(
        title: '선택한 날들을 ${isRest ? '휴회일' : "팀별 회의일"}로\n지정하시겠어요?',
        content: '확정 이후에는 날짜를 변경할 수 없어요.',
        onPressed: () async {
          if (isRest) {
            await firestoreWriter.confirmRestDate(semester, selectedDates);
          } else {
            await firebaseInstance.db
                .collection('information')
                .doc('meetingTime')
                .update({
              'teamMeeting': FieldValue.arrayUnion(selectedDates),
            });
          }
          selectedIndexes.clear();
          selectedDates.clear();
          setState(() {});
          if (!context.mounted) return;
          Navigator.pop(context);
          context.pop();
          AppSnackBar.showFlushBar(context, "신청되었습니다.", 100, true);
        },
      ),
    );
  }
}
