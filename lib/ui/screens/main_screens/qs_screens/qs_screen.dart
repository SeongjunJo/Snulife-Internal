import 'package:flutter/material.dart';

import '../../../../logics/common_instances.dart';

class QSPage extends StatelessWidget {
  const QSPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: appColors.grey0,
      child: const Center(
        child: Text('QS Page'),
      ),
    );
  }
}
