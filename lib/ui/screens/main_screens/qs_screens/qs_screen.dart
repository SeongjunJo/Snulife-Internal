import 'package:flutter/material.dart';

import '../../../../logics/common_instances.dart';

class QSPage extends StatefulWidget {
  const QSPage({super.key, required this.currentSemester});

  final String currentSemester;

  @override
  State<QSPage> createState() => _QSPageState();
}

class _QSPageState extends State<QSPage> {
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
                  .confirmRestDate(widget.currentSemester, '0229')
                  .then((_) => setState(() => isLoading = false));
            },
            child: const Text('휴회 지정'),
          ),
          const SizedBox(height: 40),
          if (isLoading) const CircularProgressIndicator(),
        ],
      ),
    );
  }
}
