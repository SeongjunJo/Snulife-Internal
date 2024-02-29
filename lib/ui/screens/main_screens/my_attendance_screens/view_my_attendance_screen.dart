import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snulife_internal/logics/providers/select_semester_states.dart';
import 'package:snulife_internal/ui/widgets/screen_specified/my_attendance_widget.dart';

import '../../../../logics/common_instances.dart';
import '../../../../logics/utils/map_util.dart';
import '../../../widgets/commons/button_widgets.dart';

class ViewMyAttendancePage extends StatefulWidget {
  const ViewMyAttendancePage({
    super.key,
    required this.isManager,
    this.name, // isManager가 true일 때만 필요
    required this.currentSemester,
  });

  final bool isManager;
  final String? name;
  final String currentSemester;

  @override
  State<ViewMyAttendancePage> createState() => _ViewMyAttendancePageState();
}

class _ViewMyAttendancePageState extends State<ViewMyAttendancePage> {
  @override
  Widget build(BuildContext context) {
    List<String> semesters = [
      ..._getLastThreeSemesters(widget.currentSemester),
      widget.currentSemester
    ];

    return Consumer<SelectSemesterStatus>(
      builder: (BuildContext context, value, _) {
        return FutureBuilder(
          future: Future.wait([
            firestoreReader.getMyAttendanceSummary(
                value.selectedSemester, firebaseInstance.userName!),
            firestoreReader.getMyAttendanceHistory(
                value.selectedSemester, firebaseInstance.userName!),
          ]),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              final attendanceSummary =
                  snapshot.data[0].data()! as Map<String, dynamic>;
              final attendanceHistory = snapshot.data[1];
              final qsSummary = MapUtil.calculateAttendanceRateAndReward(
                  attendanceSummary, {}); // 분기에 대해서만 계산

              return Container(
                color: appColors.grey0,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  children: [
                    const SizedBox(height: 24),
                    widget.isManager
                        ? Text(widget.name!, style: appFonts.h1)
                        : const SizedBox(),
                    SizedBox(height: widget.isManager ? 20 : 0),
                    _AttendanceSummaryContainer(
                      isQSSummary: true, // 상단 박스
                      firstSummary: attendanceSummary['sum'].toString(),
                      secondSummary:
                          '${qsSummary['attendanceRate'].toString()}%',
                      thirdSummary: qsSummary['reward'].toString(),
                    ),
                    const SizedBox(height: 12),
                    _AttendanceSummaryContainer(
                      isQSSummary: false, // 하단 박스
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
                    const SizedBox(height: 16),
                    // right end drop down
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SemesterDropDownMenu(
                          semesters: semesters,
                          onSelected: value.changeSemester,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
                          lateOrAbsence: !isRestDate
                              ? attendanceHistory[index].attendance
                              : "휴회",
                          isAuthorized: attendanceHistory[index].isAuthorized,
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(height: 8);
                      },
                    ),
                    const SizedBox(height: 70),
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
      height: 60,
      decoration: BoxDecoration(
        color: appColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: 88,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isQSSummary ? '총 회의 ' : '출석 ',
                  style: appFonts.b1.copyWith(color: appColors.grey7),
                ),
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
          Container(width: 1, height: 16, color: appColors.grey5),
          SizedBox(
            width: 88,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isQSSummary ? '' : '지각 ',
                  style: appFonts.b1.copyWith(color: appColors.grey7),
                ),
                Text(
                  secondSummary,
                  style: appFonts.b1.copyWith(
                    color: appColors.grey7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                isQSSummary
                    ? const SizedBox()
                    : Row(
                        children: [
                          Text(
                            ' (',
                            style: appFonts.b1.copyWith(color: appColors.grey7),
                          ),
                          Text(
                            badLate!,
                            style: appFonts.b1.copyWith(
                              color: appColors.failure,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            ')',
                            style: appFonts.b1.copyWith(color: appColors.grey7),
                          ),
                        ],
                      ),
              ],
            ),
          ),
          Container(width: 1, height: 16, color: appColors.grey5),
          SizedBox(
            width: 88,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isQSSummary ? 'QS비 ' : '결석 ',
                  style: appFonts.b1.copyWith(color: appColors.grey7),
                ),
                Text(
                  thirdSummary,
                  style: appFonts.b1.copyWith(
                    color: appColors.grey7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                isQSSummary
                    ? const SizedBox()
                    : Row(
                        children: [
                          Text(
                            ' (',
                            style: appFonts.b1.copyWith(color: appColors.grey7),
                          ),
                          Text(
                            badAbsent!,
                            style: appFonts.b1.copyWith(
                              color: appColors.failure,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            ')',
                            style: appFonts.b1.copyWith(color: appColors.grey7),
                          ),
                        ],
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
        "$currentYear -1",
        "$currentYear-S"
      ];
    case "W":
      lastThreeSemesters = [
        "$currentYear -1",
        "$currentYear-S",
        "$currentYear-2"
      ];
  }

  return lastThreeSemesters;
}
