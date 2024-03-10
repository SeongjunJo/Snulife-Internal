import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snulife_internal/router.dart';

import '../../../logics/common_instances.dart';
import '../../widgets/screen_specified/setting_widget.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool switchValue = true;

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
          GestureDetector(
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              context.goNamed(AppRoutePath.login);
            },
            child: const SettingRow(
                title: "계정 관리 (임시 로그 아웃)", trailing: RightArrow()),
          ),
          const SizedBox(height: 14),
          Divider(height: 1, thickness: 1, color: appColors.grey3),
          const SizedBox(height: 14),
          SettingRow(
            title: "시스템 알림 설정",
            trailing: Transform.scale(
              scale: 0.8,
              child: CupertinoSwitch(
                // This bool value toggles the switch.
                value: switchValue,
                activeColor: appColors.slBlue,
                onChanged: (bool? value) {
                  setState(
                    () {
                      switchValue = value ?? false;
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
