import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snulife_internal/logics/providers/select_semester_states.dart';
import 'package:snulife_internal/logics/utils/string_util.dart';
import 'package:snulife_internal/ui/widgets/commons/modal_widgets.dart';

import '../../../../logics/common_instances.dart';
import '../../../widgets/commons/button_widgets.dart';
import '../../../widgets/commons/shimmer.dart';
import '../my_attendance_screens/view_my_attendance_screen.dart';

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
    return Consumer<DropdownSelectionStatus>(
      builder: (context, value, child) {
        final String lastSemester =
            StringUtil.convertHalfToQuarters(widget.lastTwoHalf.last).last;
        List<String> semesters =
            StringUtil.convertHalfToQuarters(value.selectedSelection);
        List<Map<String, String>> userQSMapList = [];

        return FutureBuilder(
          future: Future.wait([
            firestoreReader.getQSMapList(
              widget.userList,
              semesters[0],
              semesters[1],
            ),
            firebaseInstance.db
                .collection('attendances')
                .doc(lastSemester)
                .get(),
          ]),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return ShimmerLoadingAnimation(
                isLoading: true,
                child: qsShimmer(),
              );
            } else if (snapshot.hasData) {
              userQSMapList = snapshot.data[0];
              final hasQSConfirmed = snapshot.data[1]['hasQSConfirmed'];
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
                          Text('${value.selectedSelection} QS',
                              style: appFonts.h1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              AppDropDownMenu(
                                dropdowns: widget.lastTwoHalf,
                                onSelected: value.changeSelection,
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _QSTotalSummaryBox(
                                    title: '총 회의', content: '$totalMeeting 번'),
                                Container(
                                    width: 1,
                                    height: 40,
                                    color: appColors.grey3),
                                _QSTotalSummaryBox(
                                    title: '총 QS비', content: '$totalReward 만원'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    } else if (index == widget.userList.length + 2) {
                      // 동아리원이 4명에서 5명으로 넘어가는 시점에서 sticky를 걸면 되는데, 그런 상황은 생기지 않음 (그래야만 함)
                      return AppExpandedButton(
                        buttonText: 'QS 확정하기',
                        onPressed: !hasQSConfirmed
                            ? () => showDialog(
                                  context: context,
                                  useRootNavigator: false,
                                  builder: (context) => ConfirmDialog(
                                    title: 'QS 정산을 확정하시겠어요?',
                                    content: '반드시 동아리원들 승급을\n마무리한 후 확정해주세요.',
                                    onPressed: () async {
                                      Future.wait([
                                        _updatePeoplePromotionCount(
                                            widget.userList, userQSMapList),
                                        firebaseInstance.db
                                            .collection('attendances')
                                            .doc(lastSemester)
                                            .update({'hasQSConfirmed': true}),
                                      ]).then((_) {
                                        Navigator.pop(context);
                                        setState(() {});
                                      });
                                    },
                                  ),
                                )
                            : null,
                      );
                    } else if (index == widget.userList.length + 3) {
                      return const SizedBox(height: 24);
                    } else {
                      return GestureDetector(
                        onTap: () async {
                          final userInfo = await firestoreReader
                              .getUserInfo(widget.userList[index - 2]);
                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => ChangeNotifierProvider(
                                create: (context) => DropdownSelectionStatus(
                                    currentSelection:
                                        StringUtil.convertHalfToQuarters(
                                  value.selectedSelection,
                                ).last),
                                child: ViewMyAttendancePage(
                                  userInfo: userInfo,
                                  isQSSummary: true, // 'QS 관리'에서 접근하면 무조건 true
                                  currentSemester: value.selectedSelection,
                                  hasQSConfirmed: hasQSConfirmed.toString(),
                                ),
                              ),
                            ),
                          );
                        },
                        child: Container(
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
                        ),
                      );
                    }
                  },
                  separatorBuilder: (context, index) {
                    if (index == widget.userList.length + 1) {
                      return const SizedBox(height: 37);
                    } else if (index == widget.userList.length + 2) {
                      return const SizedBox();
                    } else {
                      return const SizedBox(height: 12);
                    }
                  },
                ),
              );
            } else {
              return Container(color: appColors.grey0);
            }
          },
        );
      },
    );
  }

  ListView qsShimmer() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Container(
              width: 161,
              height: 30,
              decoration: BoxDecoration(
                color: appColors.grey1,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 175,
                  height: 40,
                  decoration: BoxDecoration(
                    color: appColors.grey1,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 28),
        Container(
          width: double.infinity,
          height: 90,
          decoration: BoxDecoration(
            color: appColors.white,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 32),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 10,
          itemBuilder: (context, index) => Container(
            width: double.infinity,
            height: 62,
            decoration: BoxDecoration(
              color: appColors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
        ),
      ],
    );
  }
}

Future _updatePeoplePromotionCount(
  List<dynamic> userList,
  List<Map<String, String>> userQSMapList,
) async {
  final List<String> promoteUserList = [];

  for (var i = 0; i < userList.length; i++) {
    double.parse(userQSMapList[i]['attendanceRate']!) >= 75
        ? promoteUserList.add(userList[i])
        : null;
  }

  for (final user in promoteUserList) {
    final userQuery = await firebaseInstance.db
        .collection('users')
        .where('name', isEqualTo: user)
        .get();
    userQuery.docs.first.reference
        .update({'promotionCount': FieldValue.increment(1)});
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
    return SizedBox(
      width: 100,
      child: Column(
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
      ),
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
