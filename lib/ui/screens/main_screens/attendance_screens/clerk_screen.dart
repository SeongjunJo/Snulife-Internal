import 'dart:async';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snulife_internal/logics/common_instances.dart';

import '../../../../logics/utils/map_util.dart';
import '../../../widgets/commons/button_widgets.dart';
import '../../../widgets/commons/modal_widgets.dart';
import '../../../widgets/screen_specified/attendance_widget.dart';

class ClerkPage extends StatefulWidget {
  const ClerkPage({
    super.key,
    required this.isManager,
    required this.thisWeekClerkDate,
    required this.clerk,
    required this.clerkMap,
    required this.currentSemester,
    required this.upcomingSemester,
  });

  final bool isManager;
  final String thisWeekClerkDate;
  final String clerk;
  final Map<String, dynamic> clerkMap;
  final String currentSemester;
  final String? upcomingSemester;

  @override
  State<ClerkPage> createState() => _ClerkPageState();
}

class _ClerkPageState extends State<ClerkPage> {
  late Map<String, dynamic> _clerkMap = widget.clerkMap;
  late final StreamSubscription _clerkMapListener;
  late List<MapEntry<String, dynamic>> _clerkList = _clerkMap.entries.toList();
  late int _selectedIndex =
      _clerkList.indexWhere((element) => element.key == widget.clerk);
  bool _hasConfirmed = false;
  late final StreamSubscription _clerkConfirmListener;
  String? _temporaryClerk;

  @override
  void initState() {
    super.initState();
    _clerkMapListener = firebaseInstance.db
        .collection('clerks')
        .snapshots()
        .listen((event) => setState(() {
              _clerkMap = MapUtil.orderClerksByCount(event);
              _clerkList = _clerkMap.entries.toList();
            }));
    _clerkConfirmListener = firebaseInstance.db
        .collection('attendances')
        .doc(widget.currentSemester)
        .collection('dates')
        .doc(widget.thisWeekClerkDate)
        .snapshots()
        .listen((event) {
      _hasConfirmed = event.data()!['hasClerkConfirmed'];
      final String confirmedClerk = event.data()!['clerk'];
      !_clerkList.any((element) => element.key == confirmedClerk)
          ? _clerkList
              .add(MapEntry(confirmedClerk, null)) // 임시 서기가 들어온 경우 clerkList 추가
          : null;
      _selectedIndex = _clerkList.indexWhere((element) =>
          element.key == confirmedClerk); // 임시 서기면 selectedIndex 업데이트 다시 해야 함
    });
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
      child: Column(
        children: [
          Expanded(
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
                const SizedBox(height: 20),
                ListView.separated(
                  // 전체 위젯이 한번에 빌드되지만, 인원수가 많지 않고 index는 필요하므로 builder 사용
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _clerkList.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == _clerkList.length) {
                      return (!widget.isManager || _hasConfirmed)
                          ? null // 일반 동아리원은 안 보임
                          : _temporaryClerk == null
                              ? GestureDetector(
                                  onTap: () async {
                                    final List<String> userList =
                                        await firestoreReader.getUserList();
                                    for (final clerk in _clerkList) {
                                      // 서기 목록은 임시 서기 대상자에서 제외
                                      userList.remove(clerk.key);
                                    }

                                    if (!context.mounted) return;
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return SelectOnlyBottomModal(
                                          height: 600,
                                          title: '임시 서기로 지정할 동아리원을 선택해주세요.',
                                          hintText:
                                              '확인 후 \'서기 확정\'을 반드시 눌러주세요.',
                                          canScroll: true,
                                          tapTexts: userList,
                                          onTapsPressed: [
                                            for (final user in userList)
                                              () => _temporaryClerk = user
                                          ],
                                          onBtnPressed: () {
                                            _temporaryClerk != null
                                                ? _selectedIndex = index
                                                : null;
                                            setState(() {});
                                            context.pop();
                                          },
                                        );
                                      },
                                    );
                                  },
                                  child: DottedBorder(
                                    stackFit: StackFit.passthrough,
                                    padding: const EdgeInsets.all(0),
                                    color: appColors.grey5,
                                    borderType: BorderType.RRect,
                                    radius: const Radius.circular(12),
                                    dashPattern: const [6, 6],
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 18, vertical: 20),
                                      decoration: const BoxDecoration(
                                          color: Colors.transparent),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                              'assets/images/icon_plus.png',
                                              width: 24,
                                              height: 24),
                                          const SizedBox(width: 12),
                                          Text('임시 서기 추가',
                                              style: appFonts.t5.copyWith(
                                                  color: appColors.grey5)),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : ClerkListItem(
                                  name: _temporaryClerk!,
                                  index: index,
                                  selectedIndex: _selectedIndex,
                                  onSelected: (widget.isManager &&
                                          !_hasConfirmed)
                                      ? () =>
                                          setState(() => _selectedIndex = index)
                                      : () {},
                                  clerkCount: null,
                                );
                    }
                    return ClerkListItem(
                      name: _clerkList[index].key,
                      index: index,
                      selectedIndex: _selectedIndex,
                      onSelected: (widget.isManager && !_hasConfirmed)
                          ? () => setState(() => _selectedIndex = index)
                          : () {},
                      clerkCount: _clerkList[index].value,
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(height: 12);
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: appColors.grey1,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Text(
                    "횟수가 가장 적은 순으로 서기가 지정되며, 연속 서기는 불가능해요.",
                    style: appFonts.c3.copyWith(color: appColors.grey6),
                  ),
                ),
                if (widget.isManager && _clerkList.length > 5)
                  Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildButton(nextClerk),
                    ],
                  )
              ],
            ),
          ),
          if (widget.isManager && _clerkList.length <= 5)
            _buildButton(nextClerk)
        ],
      ),
    );
  }

  Column _buildButton(String nextClerk) {
    return Column(
      children: [
        Row(
          children: [
            AppExpandedButton(
              buttonText: "서기 확정",
              onPressed: !_hasConfirmed
                  ? () {
                      _hasConfirmed = true;
                      firebaseInstance.db
                          .collection('attendances')
                          .doc(widget.currentSemester)
                          .collection('dates')
                          .doc(widget.thisWeekClerkDate)
                          .update({'hasClerkConfirmed': true});

                      if (_temporaryClerk == null) {
                        nextClerk = MapUtil.getNextClerk(
                          _clerkMap,
                          _clerkList[_selectedIndex].key,
                        );
                        firestoreWriter.writeConfirmedClerk(
                          widget.currentSemester,
                          widget.upcomingSemester,
                          widget.thisWeekClerkDate,
                          _clerkList[_selectedIndex].key,
                          nextClerk,
                          false,
                        );
                      } else {
                        firestoreWriter.writeConfirmedClerk(
                          widget.currentSemester,
                          widget.upcomingSemester,
                          widget.thisWeekClerkDate,
                          _temporaryClerk!,
                          widget.clerk,
                          true,
                        );
                      }
                    }
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
