import 'package:flutter/material.dart';

import '../../main.dart';
import '../widgets/setting_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: appColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 14),
          SettingRow(title: "프로필 사진 변경", trailing: RightArrow()),
          SettingRow(title: "비밀번호 변경", trailing: RightArrow()),
        ],
      ),
    );
  }
}
