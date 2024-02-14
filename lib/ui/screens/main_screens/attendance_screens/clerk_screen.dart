import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snulife_internal/logics/common_instances.dart';
import 'package:snulife_internal/ui/widgets/commons/text_widgets.dart';

import '../../../../logics/utils/map_util.dart';
import '../../../widgets/commons/button_widgets.dart';
import '../../../widgets/screen_specified/attendance_widget.dart';

class ClerkPage extends StatefulWidget {
  const ClerkPage({super.key});

  @override
  State<ClerkPage> createState() => _ClerkPageState();
}

class _ClerkPageState extends State<ClerkPage> {
  late int selectedIndex;
  bool hasSelected = false;
  late final Future<Map<String, dynamic>> clerkMap;
  late List<MapEntry<String, dynamic>> clerkList;
  late String clerk;
  late String nextClerk;

  @override
  void initState() {
    super.initState();
    clerkMap = firestoreReader.getClerkMap();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: appColors.grey1,
      child: FutureBuilder(
        future: clerkMap,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            clerkList = snapshot.data.entries.toList();
            clerk = MapUtil.getLeastKey(snapshot.data);
            nextClerk = MapUtil.getNextLeastKey(snapshot.data);
            selectedIndex = hasSelected
                ? selectedIndex
                : clerkList.indexWhere((element) => element.key == clerk);

            return ListView(
              children: [
                const SizedBox(height: 32),
                Text("서기 로테이션", style: appFonts.h1),
                const SizedBox(height: 8),
                ClerkRotationText(clerk: clerk, nextClerk: nextClerk),
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
                            hasSelected = true;
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
                AppLargeButton(
                    buttonText: "돌아가기", onPressed: () => context.pop()),
                const SizedBox(height: 40),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
