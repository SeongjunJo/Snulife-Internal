import 'package:flutter/material.dart';
import 'package:snulife_internal/ui/widgets/commons/button_widgets.dart';

import '../../../main.dart';
import '../../widgets/screen_specified/login_widget.dart';

class ForgottenPasswordPage extends StatefulWidget {
  const ForgottenPasswordPage({super.key});

  @override
  State<ForgottenPasswordPage> createState() => _ForgottenPasswordPageState();
}

class _ForgottenPasswordPageState extends State<ForgottenPasswordPage> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO 디자인 확정 후 반영
    return Scaffold(
      appBar: AppBar(
        title: const Text("비밀번호 초기화"),
        toolbarHeight: 50,
        titleSpacing: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 45, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("이메일을 입력해주세요", style: appFonts.h1),
            const SizedBox(height: 60),
            LoginTextField(
              type: "이메일",
              controller: emailController,
              isForgottenPasswordField: true,
            ),
            const SizedBox(height: 60),
            AppLargeButton(buttonText: '비밀번호 초기화하기', onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
