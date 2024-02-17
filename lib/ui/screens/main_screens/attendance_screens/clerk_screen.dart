import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snulife_internal/logics/common_instances.dart';

import '../../../../logics/utils/map_util.dart';
import '../../../widgets/commons/button_widgets.dart';
import '../../../widgets/screen_specified/attendance_widget.dart';

class ClerkPage extends StatefulWidget {
  const ClerkPage({super.key, required this.clerkMap});

  final Map<String, dynamic> clerkMap;

  @override
  State<ClerkPage> createState() => _ClerkPageState();
}

class _ClerkPageState extends State<ClerkPage> {
  late int selectedIndex;

  late final Map<String, dynamic> _clerkMap = widget.clerkMap;
  late List<MapEntry<String, dynamic>> clerkList;

  late String clerk;
  late String nextClerk;

  @override
  void initState() {
    super.initState();
    clerkList = _clerkMap.entries.toList();
    clerk = MapUtil.getLeastKey(_clerkMap);
    nextClerk = MapUtil.getNextLeastKey(_clerkMap);
    selectedIndex = clerkList.indexWhere((element) => element.key == clerk);
  }

  @override
  Widget build(BuildContext context) {
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
                    "오늘의 서기는 ",
                    style: appFonts.b2.copyWith(color: appColors.grey7),
                  ),
                  Text(
                    clerk,
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
                    "다음 서기는 ",
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
                  onSelected: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  clerkCount: clerkList[index].value,
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 8);
              },
            ),
          ),
          const SizedBox(height: 70),
          AppExpandedButton(buttonText: "돌아가기", onPressed: () => context.pop()),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
