import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snulife_internal/logics/providers/select_semester_states.dart';
import 'package:snulife_internal/ui/widgets/screen_specified/my_attendance_widget.dart';

import '../../../../logics/common_instances.dart';
import '../../../../logics/utils/map_util.dart';
import '../../../widgets/commons/button_widgets.dart';

class ViewMyAttendancePage extends StatefulWidget {
  const ViewMyAttendancePage({super.key, required this.currentSemester});

  final String currentSemester;

  @override
  State<ViewMyAttendancePage> createState() => _ViewMyAttendancePageState();
}

class _ViewMyAttendancePageState extends State<ViewMyAttendancePage> {
  List<AttendanceStatus> attendanceHistory = [];

  @override
  Widget build(BuildContext context) {
    attendanceHistory.clear();
    List<String> semesters = [
      ..._getLastTwoSemesters(widget.currentSemester),
      widget.currentSemester
    ];

    return Consumer<SelectSemesterStatus>(
      builder: (BuildContext context, value, _) {
        return FutureBuilder(
          future: Future.wait([
            firestoreReader.getMyAttendanceSummary(value.selectedSemester),
            firestoreReader.getMyAttendanceHistory(value.selectedSemester),
          ]),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              attendanceHistory = snapshot.data[1];

              return Container(
                color: appColors.grey0,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  children: [
                    const SizedBox(height: 24),
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: appColors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "총 회의 수 ",
                            style: appFonts.b1.copyWith(color: appColors.grey7),
                          ),
                          Text(
                            "${snapshot.data[0]['sum']}",
                            style: appFonts.b1.copyWith(
                              color: appColors.grey7,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: appColors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              children: [
                                Text("출석 ",
                                    style: appFonts.b1
                                        .copyWith(color: appColors.grey7)),
                                Text(
                                  "${snapshot.data[0]['present']}",
                                  style: appFonts.b1.copyWith(
                                    color: appColors.grey7,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                                width: 1, height: 16, color: appColors.grey5),
                            Row(
                              children: [
                                Text("지각 ",
                                    style: appFonts.b1
                                        .copyWith(color: appColors.grey7)),
                                Text(
                                  '${snapshot.data[0]['late'] + snapshot.data[0]['badLate']}', // 일반 동아리원은 사유 여부 안 보여줌
                                  style: appFonts.b1.copyWith(
                                    color: appColors.grey7,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                                width: 1, height: 16, color: appColors.grey5),
                            Row(
                              children: [
                                Text("결석 ",
                                    style: appFonts.b1
                                        .copyWith(color: appColors.grey7)),
                                Text(
                                  "${snapshot.data[0]['absent'] + snapshot.data[0]['badAbsent']}", // 일반 동아리원은 사유 여부 안 보여줌
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
                          isReadOnly: true,
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

List<String> _getLastTwoSemesters(String semester) {
  final currentYear = int.parse(semester.split("-")[0]);
  final currentSemester = semester.split("-")[1];
  late List<String> lastTwoSemesters;

  switch (currentSemester) {
    case "1":
      lastTwoSemesters = ["${currentYear - 1}-2", "${currentYear - 1}-W"];
    case "S":
      lastTwoSemesters = ["${currentYear - 1}-W", "$currentYear-1"];
    case "2":
      lastTwoSemesters = ["$currentYear -1", "$currentYear-S"];
    case "W":
      lastTwoSemesters = ["$currentYear-S", "$currentYear-2"];
  }

  return lastTwoSemesters;
}
