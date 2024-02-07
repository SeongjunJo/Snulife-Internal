import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snulife_internal/router.dart';

import '../../main.dart';
import '../widgets/screen_specified/setting_widget.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: appColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 14),
          SettingRow(
            title: "프로필 관리",
            trailing: const RightArrow(),
            onTap: () => context.pushNamed(AppRoutePath.profile),
          ),
          const SettingRow(title: "계정 관리", trailing: RightArrow()),
          const SizedBox(height: 14),
          Divider(height: 1, thickness: 1, color: appColors.grey3),
          const SizedBox(height: 14),
          const SettingRow(title: "시스템 알림 설정", trailing: NotificationSwitch()),
        ],
      ),
    );
  }
}
