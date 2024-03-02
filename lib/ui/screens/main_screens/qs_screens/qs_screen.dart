import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snulife_internal/ui/widgets/commons/button_widgets.dart';

import '../../../../logics/common_instances.dart';
import '../../../../logics/utils/map_util.dart';

class QSPage extends StatefulWidget {
  const QSPage({
    super.key,
    required this.currentSemester,
    required this.userList,
  });

  final String currentSemester;
  final List userList;

  @override
  State<QSPage> createState() => _QSPageState();
}

class _QSPageState extends State<QSPage> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> userQSMapList = [];

    return FutureBuilder(future: memoizer.runOnce(
      () async {
        for (final user in widget.userList) {
          late final DocumentSnapshot<Map> preSummary;
          late final DocumentSnapshot<Map> postSummary;
          late final Map<String, dynamic> preSummaryMap;
          late final Map<String, dynamic> postSummaryMap;

          final futureList = await Future.wait([
            // TODO 실제 학기 및 user로 바꾸기
            firestoreReader.getMyAttendanceSummary('2024-1', '홍신입'),
            firestoreReader.getMyAttendanceSummary('2024-S', '홍신입'),
          ]);
          preSummary = futureList[0];
          postSummary = futureList[1];
          preSummaryMap = preSummary.data()! as Map<String, dynamic>;
          postSummary.exists
              ? postSummaryMap = postSummary.data()! as Map<String, dynamic>
              : {};
          userQSMapList.add(MapUtil.calculateAttendanceRateAndReward(
              preSummaryMap, postSummaryMap));
        }
        return userQSMapList;
      },
    ), builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
      if (snapshot.hasData) {
        final totalMeeting = userQSMapList
            .map((e) => int.parse(e['totalMeeting']!))
            .reduce((value, element) => value > element ? value : element)
            .toString();
        // 신입 & .5 기수는 학기 중간에 들어와서 총 회의 수가 적음; 총 회의 수의 최댓값 구함
        final totalReward = userQSMapList
            .map((e) => double.parse(e['reward']!))
            .reduce((value, element) => value + element)
            .toStringAsFixed(2);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          color: appColors.grey0,
          child: ListView.separated(
            itemCount: widget.userList.length + 3,
            itemBuilder: (context, index) {
              // ListView로 ListView.separated를 감싼 다른 화면과 달리
              // 이렇게 index = 0일 때 list가 아닌 UI를 보여주게 해서 ListView를 한 번만 쓰면
              // 다른 화면이 모든 item을 한 번에 랜더링하는 것과 달리 각 item이 화면에 올 때만 랜더링 됨
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text('2023년 하반기 QS', style: appFonts.h1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppDropDownMenu(
                          dropdowns: const ['2023년 상반기', '2023년 하반기'],
                          onSelected: (_) {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 19),
                      decoration: BoxDecoration(
                        color: appColors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _QSTotalSummaryBox(
                              title: '총 회의', content: '$totalMeeting 번'),
                          Container(
                              width: 1, height: 40, color: appColors.grey3),
                          _QSTotalSummaryBox(
                              title: '총 QS비', content: '$totalReward 만원'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              } else if (index == widget.userList.length + 1) {
                return AppExpandedButton(
                  buttonText: '엑셀 파일 다운받기',
                  onPressed: () {},
                );
              } else if (index == widget.userList.length + 2) {
                return const SizedBox(height: 12);
              } else {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                  decoration: BoxDecoration(
                    color: appColors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.userList[index - 1],
                        style: appFonts.t3.copyWith(
                          color: appColors.grey7,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(
                        children: [
                          _QSPersonalSummaryBox(
                              title: '출석률',
                              content:
                                  '${userQSMapList[index - 1]['attendanceRate']}%'),
                          const SizedBox(width: 10),
                          Container(
                              width: 1, height: 16, color: appColors.grey3),
                          const SizedBox(width: 10),
                          _QSPersonalSummaryBox(
                              title: 'QS비',
                              content:
                                  '${userQSMapList[index - 1]['reward']}만원'),
                          const SizedBox(width: 8),
                          Image.asset('assets/images/icon_arrow_right.png',
                              width: 20, height: 20),
                        ],
                      ),
                    ],
                  ),
                );
              }
            },
            separatorBuilder: (context, index) {
              if (index == widget.userList.length) {
                return const SizedBox(height: 73);
              } else {
                return const SizedBox(height: 12);
              }
            },
          ),
        );
      } else {
        return Container(color: appColors.grey0);
      }
    });
  }
}

class _QSTotalSummaryBox extends StatelessWidget {
  const _QSTotalSummaryBox({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: appFonts.b5.copyWith(color: appColors.grey7)),
        const SizedBox(height: 12),
        Text(
          content,
          style: appFonts.b1.copyWith(
            color: appColors.grey7,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _QSPersonalSummaryBox extends StatelessWidget {
  const _QSPersonalSummaryBox({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: appFonts.t5.copyWith(color: appColors.grey7)),
        const SizedBox(width: 6),
        Text(
          content,
          style: appFonts.t5.copyWith(
            color: appColors.grey7,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
