import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snulife_internal/ui/widgets/screen_specified/my_attendance_widget.dart';

import '../../../../logics/common_instances.dart';
import '../../../widgets/commons/button_widgets.dart';
import '../../../widgets/commons/modal_widgets.dart';
import '../../../widgets/commons/snackbar_widget.dart';

class ManageClubPage extends StatefulWidget {
  const ManageClubPage({super.key, required this.currentSemester});

  final String currentSemester;

  @override
  State<ManageClubPage> createState() => _ManageClubPageState();
}

class _ManageClubPageState extends State<ManageClubPage> {
  int _tabTagIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: appColors.grey0,
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              AppTabTag(
                title: '일정 관리',
                isTurnedOn: _tabTagIndex == 1,
                onPressed: () => setState(() => _tabTagIndex = 1),
              ),
              const SizedBox(width: 8),
              AppTabTag(
                title: '회의일 지정',
                isTurnedOn: _tabTagIndex == 2,
                onPressed: () => setState(() => _tabTagIndex = 2),
              ),
              const SizedBox(width: 8),
              AppTabTag(
                title: '동아리원 관리',
                isTurnedOn: _tabTagIndex == 3,
                onPressed: () => setState(() => _tabTagIndex = 3),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_tabTagIndex == 1)
            _SetRestOrTeemMeetingPage(currentSemester: widget.currentSemester)
          else if (_tabTagIndex == 2)
            const Text('회의일 지정')
          else
            const Text('동아리원 관리'),
        ],
      ),
    );
  }
}

class _SetRestOrTeemMeetingPage extends StatefulWidget {
  const _SetRestOrTeemMeetingPage({required this.currentSemester});

  final String currentSemester;

  @override
  State<_SetRestOrTeemMeetingPage> createState() =>
      _SetRestOrTeemMeetingPageState();
}

class _SetRestOrTeemMeetingPageState extends State<_SetRestOrTeemMeetingPage> {
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
          allMeetingDates.removeWhere(
              (element) => int.parse(element) < int.parse(localToday));
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
                                    return BottomModal(
                                        title: '변경 유형을 선택해주세요.',
                                        firstTapText: '휴회',
                                        secondTapText: '팀별 회의',
                                        onFirstTap: () => _isRest.value = true,
                                        onSecondTap: () =>
                                            _isRest.value = false,
                                        onPressed: _isRest.value != null
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
                } else if (index == allMeetingDates.length + 4) {
                  return const SizedBox(height: 62);
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
          if (!mounted) return;
          Navigator.pop(context);
          context.pop();
          AppSnackBar.showFlushbar(context, "신청되었습니다.", true);
        },
      ),
    );
  }
}
