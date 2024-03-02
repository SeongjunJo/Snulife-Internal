import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snulife_internal/logics/providers/select_semester_states.dart';

import '../../../../logics/common_instances.dart';
import '../../../../logics/utils/map_util.dart';
import '../../../widgets/commons/button_widgets.dart';

class QSPage extends StatefulWidget {
  const QSPage({
    super.key,
    required this.userList,
    required this.lastTwoHalf,
  });

  final List userList;
  final List<String> lastTwoHalf;

  @override
  State<QSPage> createState() => _QSPageState();
}

class _QSPageState extends State<QSPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SelectSemesterStatus>(
      builder: (context, value, child) {
        List<String> semesters = _convertHalfToQuarters(value.selectedSemester);
        List<Map<String, String>> userQSMapList = [];

        return FutureBuilder(
            future: _getQSMapList(widget.userList, semesters[0], semesters[1]),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                userQSMapList = snapshot.data;
                final totalMeeting = userQSMapList
                    .map((element) => int.parse(element['totalMeeting']!))
                    .reduce((value, e) => value > e ? value : e)
                    // 신입 & .5 기수는 학기 중간에 들어와서 총 회의 수가 적음; 총 회의 수의 최댓값 구함
                    .toString();
                final totalReward = userQSMapList
                    .map((element) => double.parse(element['reward']!))
                    .reduce((value, element) => value + element)
                    .toStringAsFixed(2);

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: appColors.grey0,
                  child: ListView.separated(
                    itemCount: widget.userList.length + 4,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            Text('${value.selectedSemester} QS',
                                style: appFonts.h1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AppDropDownMenu(
                                  dropdowns: widget.lastTwoHalf,
                                  onSelected: value.changeSemester,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return index == 1
                            ? const SizedBox(height: 100)
                            : index == 2
                                ? Center(
                                    child: CircularProgressIndicator(
                                    color: appColors.slBlue,
                                  ))
                                : const SizedBox();
                      } else if (index == 1) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 19),
                              decoration: BoxDecoration(
                                color: appColors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _QSTotalSummaryBox(
                                      title: '총 회의',
                                      content: '$totalMeeting 번'),
                                  Container(
                                      width: 1,
                                      height: 40,
                                      color: appColors.grey3),
                                  _QSTotalSummaryBox(
                                      title: '총 QS비',
                                      content: '$totalReward 만원'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      } else if (index == widget.userList.length + 2) {
                        return AppExpandedButton(
                          buttonText: '엑셀 파일 다운받기',
                          onPressed: () {},
                        );
                      } else if (index == widget.userList.length + 3) {
                        return const SizedBox(height: 12);
                      } else {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 20),
                          decoration: BoxDecoration(
                            color: appColors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.userList[index - 2],
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
                                          '${userQSMapList[index - 2]['attendanceRate']}%'),
                                  const SizedBox(width: 10),
                                  Container(
                                      width: 1,
                                      height: 16,
                                      color: appColors.grey3),
                                  const SizedBox(width: 10),
                                  _QSPersonalSummaryBox(
                                      title: 'QS비',
                                      content:
                                          '${userQSMapList[index - 2]['reward']}만원'),
                                  const SizedBox(width: 8),
                                  Image.asset(
                                      'assets/images/icon_arrow_right.png',
                                      width: 20,
                                      height: 20),
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    separatorBuilder: (context, index) {
                      if (index == widget.userList.length + 1) {
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
      },
    );
  }
}

List<String> _convertHalfToQuarters(String half) {
  final currentYear = int.parse(half.substring(0, 4));
  final currentHalf = half.split(' ')[1];
  late final List<String> quarters;

  currentHalf == '상반기'
      ? quarters = ['$currentYear-1', '$currentYear-S']
      : quarters = ['$currentYear-2', '$currentYear-W'];

  return quarters;
}

Future _getQSMapList(
    List userList, String preSemester, String postSemester) async {
  final List<Map<String, String>> userQSMapList = [];

  for (final user in userList) {
    late final DocumentSnapshot<Map> preSummary;
    late final DocumentSnapshot<Map> postSummary;
    late final Map<String, dynamic> preSummaryMap;
    late final Map<String, dynamic> postSummaryMap;

    final futureList = await Future.wait([
      // TODO user로 바꾸기
      firestoreReader.getMyAttendanceSummary(preSemester, '홍신입'),
      firestoreReader.getMyAttendanceSummary(postSemester, '홍신입'),
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
