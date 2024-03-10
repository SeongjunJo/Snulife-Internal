import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../logics/common_instances.dart';
import '../../../../widgets/commons/button_widgets.dart';
import '../../../../widgets/commons/snackbar_widget.dart';

class SetNextMeeting extends StatefulWidget {
  const SetNextMeeting({super.key, required this.currentSemester});

  final String currentSemester;

  @override
  State<SetNextMeeting> createState() => _SetNextMeetingState();
}

class _SetNextMeetingState extends State<SetNextMeeting> {
  late final String upcomingSemester =
      _getUpcomingSemester(widget.currentSemester);
  final ValueNotifier<Step> step = ValueNotifier(Step.date);
  late String pickerTitle;
  late String pickerBackBtnText;
  late Function() pickerBackBtnOnPressed;
  late String pickerConfirmBtnText;
  late Function() pickerConfirmBtnOnPressed;
  final nextMeetingDateTime = <DateTime>[];
  bool isLoading = false;
  bool showFlushBar = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: memoizer.runOnce(() async {
        final result = await _getMeetingStartDate(upcomingSemester);
        if (result.isEmpty) {
          return _getMeetingStartDate(widget.currentSemester);
        } else {
          return result;
        }
      }),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          final String startDate = snapshot.data[0];
          final String startTime = snapshot.data[1];
          final year = int.parse(widget.currentSemester.split('-').first);
          final month = int.parse(
              startDate.substring(0, 2).replaceFirst(RegExp(r'0'), ''));
          final date = int.parse(startDate.substring(2, 4));
          final String day = _getDay(DateTime(year, month, date).weekday);
          final hour = int.parse(startTime.substring(0, 2));
          final minute = int.parse(startTime.substring(2, 4));
          final isAM = hour < 12;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            showFlushBar && snapshot.connectionState == ConnectionState.done
                ? {
                    AppSnackBar.showFlushbar(context, '변경되었습니다.', true),
                    showFlushBar = false
                  }
                : null;
          });

          return Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('다음 정규 회의 시작 일자를\n지정해주세요.', style: appFonts.h1),
                const SizedBox(height: 20),
                Text(
                  '현재 지정된 첫 회의일',
                  style: appFonts.t5.copyWith(color: appColors.slBlue),
                ),
                const SizedBox(height: 12),
                isLoading
                    ? Center(
                        child:
                            CircularProgressIndicator(color: appColors.slBlue))
                    : Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 19),
                        decoration: BoxDecoration(
                          color: appColors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$year년 $month월 $date일 $day',
                              style: appFonts.b1
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${isAM ? '오전' : '오후'} ${isAM ? hour : hour - 12}시 $minute분',
                              style: appFonts.b1
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: appColors.grey1,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Text(
                    "현재 분기의 마지막 회의 날에 다음 정규회의 일정을 지정해주세요.\n확정 후 변경할 수 없으니 신중히 지정해주세요.",
                    style: appFonts.c3.copyWith(color: appColors.grey6),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    AppExpandedButton(
                      buttonText: '변경',
                      onPressed: () => showCupertinoModalPopup(
                        context: context,
                        useRootNavigator: false,
                        builder: (context) => buildCupertinoDatePicker(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  ValueListenableBuilder<Step> buildCupertinoDatePicker() {
    step.value = Step.date;
    nextMeetingDateTime.clear();
    DateTime selectedDateTime = DateTime.now();
    int year = 0;
    int month = 0;
    int day = 0;
    int hour = 0;
    int minute = 0;
    String weekDay = '';
    bool isAM = false;

    Widget buildContainerChild(Step stepValue) {
      if (nextMeetingDateTime.isNotEmpty) {
        year = nextMeetingDateTime.first.year;
        month = nextMeetingDateTime.first.month;
        day = nextMeetingDateTime.first.day;
        hour = nextMeetingDateTime.last.hour;
        minute = nextMeetingDateTime.last.minute;
        weekDay = _getDay(nextMeetingDateTime.first.weekday);
        isAM = hour < 12;
      }

      final Widget datePicker = CupertinoDatePicker(
        key: UniqueKey(),
        mode: CupertinoDatePickerMode.date,
        minimumYear: 2024,
        maximumYear: 2100,
        use24hFormat: true,
        onDateTimeChanged: (newDate) => selectedDateTime = newDate,
      );

      final Widget timePicker = CupertinoDatePicker(
        key: UniqueKey(),
        mode: CupertinoDatePickerMode.time,
        use24hFormat: true,
        onDateTimeChanged: (newDate) => selectedDateTime = newDate,
      );

      final Widget confirm = SizedBox(
        width: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  '$year년 $month월 $day일 $weekDay\n${isAM ? '오전' : '오후'} ${isAM ? hour : hour - 12}시 $minute분',
                  textAlign: TextAlign.center,
                  style: appFonts.h1.copyWith(
                    color: appColors.grey8,
                    height: 1.5,
                  )),
            ],
          ),
        ),
      );

      switch (stepValue) {
        case Step.date:
          return datePicker;
        case Step.time:
          return timePicker;
        case Step.confirm:
          return confirm;
      }
    }

    return ValueListenableBuilder<Step>(
      valueListenable: step,
      builder: (context, Step value, _) {
        switch (step.value) {
          case Step.date:
            pickerTitle = '원하시는 날짜를 선택해주세요.';
            pickerBackBtnText = '취소';
            pickerBackBtnOnPressed = () => context.pop();
            pickerConfirmBtnText = '다음';
            pickerConfirmBtnOnPressed = () {
              nextMeetingDateTime.add(selectedDateTime);
              step.value = Step.time;
            };
          case Step.time:
            pickerTitle = '원하시는 시간을 선택해주세요.';
            pickerBackBtnText = '이전';
            pickerBackBtnOnPressed = () {
              nextMeetingDateTime.clear();
              step.value = Step.date;
            };
            pickerConfirmBtnText = '다음';
            pickerConfirmBtnOnPressed = () {
              nextMeetingDateTime.add(selectedDateTime);
              step.value = Step.confirm;
            };
          case Step.confirm:
            pickerTitle = '해당 날짜/시간으로 변경하시겠어요?';
            pickerBackBtnText = '이전';
            pickerBackBtnOnPressed = () {
              nextMeetingDateTime.removeLast();
              step.value = Step.time;
            };
            pickerConfirmBtnText = '확인';
            pickerConfirmBtnOnPressed = () async {
              setState(() => isLoading = true);
              context.pop();

              final String nextMeetingDate =
                  '${month.toString().padLeft(2, '0')}${day.toString().padLeft(2, '0')}';
              final String nextMeetingTime =
                  '${hour.toString().padLeft(2, '0')}${minute.toString().padLeft(2, '0')}';

              await firestoreWriter.createNextMeeting(
                  widget.currentSemester, nextMeetingDate, nextMeetingTime);

              setState(() {
                isLoading = false;
                showFlushBar = true;
              });
            };
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: appColors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(pickerTitle, style: appFonts.tm),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Container(
              height: 150,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(color: appColors.white),
              child: buildContainerChild(step.value),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 30, bottom: 24),
              decoration: BoxDecoration(color: appColors.white),
              child: Row(
                children: [
                  AppExpandedButton(
                    buttonText: pickerBackBtnText,
                    onPressed: pickerBackBtnOnPressed,
                    isCancelButton: true,
                  ),
                  const SizedBox(width: 8),
                  AppExpandedButton(
                    buttonText: pickerConfirmBtnText,
                    onPressed: pickerConfirmBtnOnPressed,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

_getUpcomingSemester(String currentSemester) {
  final year = int.parse(currentSemester.split('-').first);
  final semester = currentSemester.split('-').last;

  switch (semester) {
    case '1':
      return '$year-S';
    case 'S':
      return '$year-2';
    case '2':
      return '$year-W';
    case 'W':
      return '${year + 1}-1';
  }
}

Future _getMeetingStartDate(String semester) async {
  final semesterRef =
      firebaseInstance.db.collection('attendances').doc(semester);
  final semesterDoc = await semesterRef.get();

  if (semesterDoc.exists) {
    final futureList = await Future.wait([
      semesterRef.collection('dates').get(),
      firebaseInstance.db.collection('information').doc('meetingTime').get(),
    ]);

    final date = (futureList[0] as QuerySnapshot).docs.first.id;
    final time = (futureList[1] as DocumentSnapshot)['time'];

    return [date, time];
  } else {
    return [];
  }
}

String _getDay(int weekday) {
  return switch (weekday) {
    1 => '월요일',
    2 => '화요일',
    3 => '수요일',
    4 => '목요일',
    5 => '금요일',
    6 => '토요일',
    7 => '일요일',
    _ => '',
  };
}

enum Step { date, time, confirm }
