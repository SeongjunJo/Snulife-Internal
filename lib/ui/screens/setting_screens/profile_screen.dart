import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../logics/common_instances.dart';
import '../../widgets/commons/snackbar_widget.dart';
import '../../widgets/screen_specified/setting_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: appColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () =>
                AppSnackBar.showFlushBar(context, "TBD (언젠가 넣을 예정)", 30, true),
            child: const SettingRow(title: "프로필 사진 변경", trailing: RightArrow()),
          ),
        ],
      ),
    );
  }
}
