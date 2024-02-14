import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snulife_internal/logics/common_instances.dart';
import 'package:snulife_internal/ui/widgets/commons/text_widgets.dart';

import '../../../widgets/commons/button_widgets.dart';
import '../../../widgets/screen_specified/attendance_widget.dart';

class ClerkPage extends StatefulWidget {
  const ClerkPage({super.key});

  @override
  State<ClerkPage> createState() => _ClerkPageState();
}

class _ClerkPageState extends State<ClerkPage> {
  late int selectedIndex;
  int clerkCount = 1;

  @override
  void initState() {
    super.initState();
    // TODO: 서기 자동 선택
    selectedIndex = 2;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: appColors.grey1,
      child: ListView(
        children: [
          const SizedBox(height: 32),
          Text("서기 로테이션", style: appFonts.h1),
          const SizedBox(height: 8),
          const ClerkRotationText(clerk: "김이름", nextClerk: '최이름'),
          const SizedBox(height: 40),
          Expanded(
            child: ListView.separated(
              // 전체 위젯이 한번에 빌드되지만, 인원수가 많지 않고 index는 필요하므로 builder 사용
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              itemBuilder: (BuildContext context, int index) {
                return ClerkListItem(
                  index: index,
                  selectedIndex: selectedIndex,
                  onSelected: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  clerkCount: clerkCount,
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 8);
              },
            ),
          ),
          const SizedBox(height: 70),
          AppLargeButton(buttonText: "돌아가기", onPressed: () => context.pop()),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
