import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snulife_internal/logics/providers/select_semester_states.dart';
import 'package:snulife_internal/ui/widgets/screen_specified/my_attendance_widget.dart';

import '../../../../logics/common_instances.dart';
import '../../../../logics/utils/string_util.dart';
import '../../../widgets/commons/button_widgets.dart';

class ViewMyAttendancePage extends StatelessWidget {
  const ViewMyAttendancePage({
    super.key,
    required this.userInfo,
    required this.isQSSummary,
    required this.currentSemester,
    this.hasQSConfirmed = 'false', // QS 화면에서 넘어갈 때만 필요
  });

  final Map userInfo;
  final bool isQSSummary;
  final String currentSemester;
  final String hasQSConfirmed;

  @override
  Widget build(BuildContext context) {
    final bool qsConfirmed = hasQSConfirmed == 'true';
    final bool isSenior = userInfo['isSenior'];
    final bool isAlum = userInfo['isAlum'];
    final int promotionCount = userInfo['promotionCount'];
    final String info = userInfo['isAlum']
        ? '알럼나이'
        : userInfo['isSenior']
            ? '시니어'
            : '주니어';
    String promotion = info;
    bool canPromote = false;
    List<String> semesters = isQSSummary
        ? []
        : [..._getLastThreeSemesters(currentSemester), currentSemester];

    return Consumer<DropdownSelectionStatus>(
      builder: (BuildContext context, value, _) {
        bool? makeFuture =
            value.selectedSelection == currentSemester ? false : null;

        semesters = isQSSummary
            ? StringUtil.convertHalfToQuarters(currentSemester)
            : semesters;

        Future getAttendanceSummary() async => isQSSummary
            ? firestoreReader.getQSMapList(
                [userInfo['name']],
                semesters.first,
                semesters.last,
              )
            : null;

        return FutureBuilder(
          future: Future.wait([
            firestoreReader.getMyAttendanceSummary(
                value.selectedSelection, userInfo['name']),
            firestoreReader.getMyAttendanceHistory(
                value.selectedSelection, userInfo['name'], makeFuture),
            getAttendanceSummary(),
          ]),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              final attendanceSummary =
                  snapshot.data[0].data()! as Map<String, dynamic>;
              final attendanceHistory = snapshot.data[1];
              final Map? qsSummary = snapshot.data[2]?.first;
              final String attendanceRate = qsSummary?['attendanceRate'] ?? '0';
              final bool isWorth = double.parse(attendanceRate) >= 75;

              if (isWorth && !qsConfirmed) {
                if (promotionCount == 1 && !isSenior) {
                  canPromote = true;
                  promotion = '시니어';
                } else if (promotionCount == 2 && !isAlum) {
                  canPromote = true;
                  promotion = '알럼나이';
                }
              }

              return Container(
                color: appColors.grey0,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  children: [
                    const SizedBox(height: 24),
                    Text(userInfo['name'], style: appFonts.h1),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        InfoTag(info: userInfo['position']),
                        const SizedBox(width: 8),
                        InfoTag(info: userInfo['team']),
                        const SizedBox(width: 8),
                        InfoTag(info: info),
                      ],
                    ),
                    const SizedBox(height: 32),
                    isQSSummary
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('$currentSemester QS 요약',
                                  style: appFonts.tm),
                              const SizedBox(height: 12),
                              _AttendanceSummaryContainer(
                                isQSSummary: true, // 상단 박스
                                firstSummary:
                                    '${qsSummary!['totalMeeting'].toString()}번',
                                secondSummary:
                                    '${qsSummary['attendanceRate'].toString()}%',
                                thirdSummary:
                                    '${qsSummary['reward'].toString()} 만원',
                              ),
                              const SizedBox(height: 12),
                              Container(
                                height: 98,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 19),
                                decoration: BoxDecoration(
                                  color: appColors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: canPromote
                                        ? appColors.slBlue
                                        : appColors.white,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '회원 단계',
                                      style: appFonts.b5.copyWith(
                                        color: appColors.grey7,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        AppStatusTag(
                                          title:
                                              Text(canPromote ? '승격' : '미변동'),
                                          isTurnedOn: canPromote,
                                          onPressed: () {},
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          promotion,
                                          style: appFonts.b1.copyWith(
                                            color: appColors.grey7,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 48),
                            ],
                          )
                        : const SizedBox(),
                    Text('분기별 출석 현황', style: appFonts.tm),
                    const SizedBox(height: 14),
                    _AttendanceSummaryContainer(
                      isQSSummary: false,
                      firstSummary: attendanceSummary['present'].toString(),
                      secondSummary: (attendanceSummary['late'] +
                              attendanceSummary['badLate'])
                          .toString(),
                      badLate: attendanceSummary['badLate'].toString(),
                      thirdSummary: (attendanceSummary['absent'] +
                              attendanceSummary['badAbsent'])
                          .toString(),
                      badAbsent: attendanceSummary['badAbsent'].toString(),
                    ),
                    const SizedBox(height: 14),
                    // right end drop down
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppDropDownMenu(
                          dropdowns: semesters,
                          onSelected: value.changeSelection,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: attendanceHistory.length,
                      itemBuilder: (BuildContext context, int index) {
                        bool isRestDate =
                            attendanceHistory[index].attendance == '휴회';

                        return MyAttendanceListItem(
                          week: index + 1,
                          date: attendanceHistory[index].date,
                          isSelected: false,
                          status: !isRestDate
                              ? attendanceHistory[index].attendance
                              : "휴회",
                          isAuthorized: attendanceHistory[index].isAuthorized,
                          isReadOnly: true,
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(height: 8);
                      },
                    ),
                    const SizedBox(height: 37),
                  ],
                ),
              );
            } else {
              return Container(color: appColors.grey0);
            }
          },
        );
      },
    );
  }
}

class _AttendanceSummaryContainer extends StatelessWidget {
  const _AttendanceSummaryContainer({
    required this.isQSSummary,
    required this.firstSummary,
    required this.secondSummary,
    this.badLate,
    required this.thirdSummary,
    this.badAbsent,
  });

  final bool isQSSummary; // 상단 박스인지 하단 박스인지
  final String firstSummary;
  final String secondSummary;
  final String? badLate; // 무단 지각
  final String thirdSummary;
  final String? badAbsent; // 무단 결석

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 19),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 70,
            child: Column(
              children: [
                Text(
                  isQSSummary ? '총 회의' : '출석',
                  style: appFonts.b5.copyWith(color: appColors.grey7),
                ),
                const SizedBox(height: 12),
                Text(
                  firstSummary,
                  style: appFonts.b1.copyWith(
                    color: appColors.grey7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 39, color: appColors.grey3),
          SizedBox(
            width: 70,
            child: Column(
              children: [
                Text(
                  isQSSummary ? '출석률' : '지각(무단)',
                  style: appFonts.b5.copyWith(color: appColors.grey7),
                ),
                const SizedBox(height: 12),
                Text(
                  '$secondSummary ${badLate != null ? '($badLate)' : ''}',
                  style: appFonts.b1.copyWith(
                    color: appColors.grey7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 39, color: appColors.grey3),
          SizedBox(
            width: 70,
            child: Column(
              children: [
                Text(
                  isQSSummary ? 'QS비' : '결석(무단)',
                  style: appFonts.b5.copyWith(color: appColors.grey7),
                ),
                const SizedBox(height: 12),
                Text(
                  '$thirdSummary ${badAbsent != null ? '($badAbsent)' : ''}',
                  style: appFonts.b1.copyWith(
                    color: appColors.grey7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<String> _getLastThreeSemesters(String semester) {
  final currentYear = int.parse(semester.split("-")[0]);
  final currentSemester = semester.split("-")[1];
  late List<String> lastThreeSemesters;

  switch (currentSemester) {
    case "1":
      lastThreeSemesters = [
        "${currentYear - 1}-S",
        "${currentYear - 1}-2",
        "${currentYear - 1}-W"
      ];
    case "S":
      lastThreeSemesters = [
        "${currentYear - 1}-2",
        "${currentYear - 1}-W",
        "$currentYear-1"
      ];
    case "2":
      lastThreeSemesters = [
        "${currentYear - 1}-W",
        "$currentYear-1",
        "$currentYear-S"
      ];
    case "W":
      lastThreeSemesters = [
        "$currentYear-1",
        "$currentYear-S",
        "$currentYear-2"
      ];
  }

  return lastThreeSemesters;
}
