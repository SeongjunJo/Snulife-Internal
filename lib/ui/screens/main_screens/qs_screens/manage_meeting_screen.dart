import 'package:flutter/material.dart';

import '../../../../logics/common_instances.dart';

class ManageMeetingPage extends StatefulWidget {
  const ManageMeetingPage({super.key, required this.currentSemester});

  final String currentSemester;

  @override
  State<ManageMeetingPage> createState() => _ManageMeetingPageState();
}

class _ManageMeetingPageState extends State<ManageMeetingPage> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: appColors.grey0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: appColors.slBlue,
              backgroundColor: appColors.subBlue2,
            ),
            onPressed: () {
              setState(() => isLoading = true);
              firestoreWriter
                  .createNextMeeting(
                    widget.currentSemester,
                    '0304',
                    '1900',
                  )
                  .then((_) => setState(() => isLoading = false));
            },
            child: const Text('다음 회의 생성'),
          ),
          const SizedBox(height: 40),
          if (isLoading) const CircularProgressIndicator(),
        ],
      ),
    );
  }
}
