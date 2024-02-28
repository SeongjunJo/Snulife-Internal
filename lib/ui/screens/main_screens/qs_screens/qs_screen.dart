import 'package:cloud_firestore/cloud_firestore.dart';
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
  late DocumentSnapshot<Map> preSummary;
  late DocumentSnapshot<Map> postSummary;
  Map<String, dynamic> preSummaryMap = {};
  Map<String, dynamic> postSummaryMap = {};
  String temp = '';

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
            onPressed: () async {
              setState(() => isLoading = true);
              // firestoreWriter
              //     .confirmRestDate(widget.currentSemester, '0229')
              //     .then((_) => setState(() => isLoading = false));

              // preSummary =
              //     await firestoreReader.getMyAttendanceSummary('2023-W', '김신입');
              // postSummary =
              //     await firestoreReader.getMyAttendanceSummary('2024-1', '김신입');
              // preSummaryMap = preSummary.data()! as Map<String, dynamic>;
              // postSummary.exists
              //     ? postSummaryMap = postSummary.data()! as Map<String, dynamic>
              //     : {};
              // temp = MapUtil.calculateAttendanceRateAndReward(
              //         preSummaryMap, postSummaryMap)
              //     .toString();

              // showDialog(
              //     context: context,
              //     builder: (context) {
              //       return ConfirmDialog(
              //         title: '12월 12일을 휴회일로 \n지정하시겠어요?',
              //         content: '휴회 확정 이후에는 날짜를 변경할 수 없어요',
              //         onPressed: () => Navigator.of(context).pop(),
              //       );
              //     });

              setState(() => isLoading = false);
            },
            child: const Text('휴회 지정'),
          ),
          const SizedBox(height: 40),
          if (isLoading) const CircularProgressIndicator(),
          const SizedBox(height: 40),
          Text(temp),
        ],
      ),
    );
  }
}
