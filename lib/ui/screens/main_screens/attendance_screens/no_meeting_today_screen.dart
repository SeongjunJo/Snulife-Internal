import 'package:flutter/material.dart';

import '../../../../logics/common_instances.dart';

class NoMeetingTodayPage extends StatelessWidget {
  const NoMeetingTodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: appColors.grey0,
      child: Center(
        child: Text(
          '오늘은 회의가 없어요.',
          style: appFonts.h1.copyWith(color: appColors.grey4),
        ),
      ),
    );
  }
}
