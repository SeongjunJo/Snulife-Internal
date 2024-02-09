import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../logics/global_values.dart';
import '../../widgets/commons/button_widgets.dart';

class ConfirmPasswordResetPage extends StatelessWidget {
  const ConfirmPasswordResetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 45, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "비밀번호 초기화 메일을\n보내드렸습니다.\n\n이메일을 확인해주세요.",
            style: appFonts.signScreensTitle,
          ),
          Column(
            children: [
              AppLargeButton(
                buttonText: '로그인 화면 돌아가기',
                onPressed: () {
                  context.pop();
                },
              ),
              const SizedBox(height: 48),
            ],
          ),
        ],
      ),
    );
  }
}
