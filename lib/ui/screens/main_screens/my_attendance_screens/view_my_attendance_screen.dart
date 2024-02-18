import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:snulife_internal/logics/providers/select_semester_states.dart';
import 'package:snulife_internal/ui/widgets/screen_specified/my_attendance_widget.dart';

import '../../../../logics/common_instances.dart';
import '../../../widgets/commons/button_widgets.dart';

class ViewMyAttendancePage extends StatelessWidget {
  const ViewMyAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> semesters = ["2023-S", "2023-2", "2023-W"];

    return Consumer<SelectSemesterStatus>(
      builder: (BuildContext context, value, _) {
        return FutureBuilder(
          future: null,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            // TODO FUTURE 정해지면 느낌표 제거
            if (!snapshot.hasData) {
              return Container(
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
                      child: Center(
                        child: Text(
                          "총 회의 수 14",
                          style: appFonts.b1.copyWith(color: appColors.grey7),
                        ),
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
                            Text("출석 10",
                                style: appFonts.b1
                                    .copyWith(color: appColors.grey7)),
                            Container(
                                width: 1, height: 16, color: appColors.grey5),
                            Text("지각 03",
                                style: appFonts.b1
                                    .copyWith(color: appColors.grey7)),
                            Container(
                                width: 1, height: 16, color: appColors.grey5),
                            Text("결석 01",
                                style: appFonts.b1
                                    .copyWith(color: appColors.grey7)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // right end drop down
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SemesterDropDownMenu(semesters: semesters),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 8,
                      itemBuilder: (BuildContext context, int index) {
                        return const MyAttendanceListItem(
                          week: 4,
                          date: '2/13',
                          isSelected: false,
                          lateOrAbsence: '결석',
                          isReadOnly: true,
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(height: 8);
                      },
                    ),
                    const SizedBox(height: 37),
                    AppExpandedButton(
                      buttonText: "돌아가기",
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(height: 62),
                  ],
                ),
              );
            } else {
              return const SizedBox();
            }
          },
        );
      },
    );
  }
}
