import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snulife_internal/logics/utils/date_util.dart';
import 'package:snulife_internal/ui/widgets/commons/button_widgets.dart';

import '../../../../logics/common_instances.dart';
import '../../../widgets/screen_specified/attendance_widget.dart';

class CheckAttendancePage extends StatelessWidget {
  const CheckAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final today = LocalDateTime.now();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      color: appColors.grey1,
      child: ListView(
        children: [
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
              itemCount: 20,
              itemBuilder: (BuildContext context, int index) {
                return const AttendanceList();
              },
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 8);
              },
            ),
          ),
          const SizedBox(height: 70),
          AppLargeButton(buttonText: "돌아가기", onPressed: () => context.pop()),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
