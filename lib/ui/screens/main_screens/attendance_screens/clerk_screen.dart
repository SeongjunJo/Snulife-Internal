import 'dart:async';

import 'package:flutter/material.dart';
import 'package:snulife_internal/logics/common_instances.dart';
import 'package:snulife_internal/logics/utils/string_util.dart';

import '../../../../logics/utils/map_util.dart';
import '../../../widgets/commons/button_widgets.dart';
import '../../../widgets/screen_specified/attendance_widget.dart';

class ClerkPage extends StatefulWidget {
  const ClerkPage({
    super.key,
    required this.isManager,
    required this.clerk,
    required this.clerkMap,
    required this.currentSemester,
    required this.upcomingSemester,
  });

  final bool isManager;
  final String clerk;
  final Map<String, dynamic> clerkMap;
  final String currentSemester;
  final String? upcomingSemester;

  @override
  State<ClerkPage> createState() => _ClerkPageState();
}

class _ClerkPageState extends State<ClerkPage> {
  final now = DateTime.now();
  late final today = StringUtil.convertDateTimeToString(now, true);
  late Map<String, dynamic> _clerkMap = widget.clerkMap;
  late final StreamSubscription _clerkMapListener;
  late List<MapEntry<String, dynamic>> clerkList = _clerkMap.entries.toList();
  late int selectedIndex =
      clerkList.indexWhere((element) => element.key == widget.clerk);
  bool hasConfirmed = false;
  late final StreamSubscription _clerkConfirmListener;

  @override
  void initState() {
    super.initState();
    _clerkMapListener = firebaseInstance.db
        .collection('clerks')
        .snapshots()
        .listen((event) => setState(() {
              _clerkMap = MapUtil.orderClerksByCount(event);
              clerkList = _clerkMap.entries.toList();
            }));
    _clerkConfirmListener = firebaseInstance.db
        .collection('attendances')
        .doc(widget.currentSemester)
        .collection('dates')
        // TODO today로 바꾸기
        .doc('0229')
        .snapshots()
        .listen((event) => hasConfirmed = event.data()!['hasClerkConfirmed']);
  }

  @override
  void dispose() {
    super.dispose();
    _clerkMapListener.cancel();
    _clerkConfirmListener.cancel();
  }

  @override
  Widget build(BuildContext context) {
    String nextClerk = MapUtil.getNextClerk(_clerkMap, widget.clerk);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: appColors.grey0,
      child: ListView(
        children: [
          const SizedBox(height: 32),
          Text("서기 로테이션", style: appFonts.h1),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "이번 주 서기는 ",
                    style: appFonts.b2.copyWith(color: appColors.grey7),
                  ),
                  Text(
                    widget.clerk,
                    style: appFonts.b2.copyWith(
                      color: appColors.grey7,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    " 님입니다.",
                    style: appFonts.b2.copyWith(color: appColors.grey7),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    "다음 주 서기는 ",
                    style: appFonts.b2.copyWith(color: appColors.grey7),
                  ),
                  Text(
                    nextClerk,
                    style: appFonts.b2.copyWith(
                      color: appColors.grey7,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    " 님이에요.",
                    style: appFonts.b2.copyWith(color: appColors.grey7),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
          Expanded(
            child: ListView.separated(
              // 전체 위젯이 한번에 빌드되지만, 인원수가 많지 않고 index는 필요하므로 builder 사용
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: clerkList.length,
              itemBuilder: (BuildContext context, int index) {
                return ClerkListItem(
                  name: clerkList[index].key,
                  index: index,
                  selectedIndex: selectedIndex,
                  onSelected: (widget.isManager && !hasConfirmed)
                      ? () => setState(() => selectedIndex = index)
                      : () {},
                  clerkCount: clerkList[index].value,
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 12);
              },
            ),
          ),
          const SizedBox(height: 70),
          widget.isManager
              ? AppExpandedButton(
                  buttonText: "서기 확정",
                  onPressed: !hasConfirmed
                      ? () {
                          hasConfirmed = true;

                          nextClerk = MapUtil.getNextClerk(
                            _clerkMap,
                            clerkList[selectedIndex].key,
                          );

                          firebaseInstance.db
                              .collection('attendances')
                              .doc(widget.currentSemester)
                              .collection('dates')
                              // TODO today로 바꾸기
                              .doc('0229')
                              .update({'hasClerkConfirmed': true});

                          firestoreWriter.writeConfirmedClerk(
                            widget.currentSemester,
                            widget.upcomingSemester,
                            clerkList[selectedIndex].key,
                            nextClerk,
                          );
                        }
                      : null,
                )
              : const SizedBox(),
          widget.isManager // ListView 때문에 Column으로 못 묶음
              ? const SizedBox(height: 24)
              : const SizedBox(),
        ],
      ),
    );
  }
}
