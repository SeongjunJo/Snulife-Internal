import 'package:flutter/material.dart';

import '../../../../logics/common_instances.dart';

class ManageMeetingPage extends StatelessWidget {
  const ManageMeetingPage({super.key, required this.currentSemester});

  final String currentSemester;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: appColors.grey0,
      child: Center(
        child: TextButton(
          style: TextButton.styleFrom(
            foregroundColor: appColors.slBlue,
            backgroundColor: appColors.subBlue2,
          ),
          onPressed: () {},
          child: const Text('다음 회의 생성'),
        ),
      ),
    );
  }
}
