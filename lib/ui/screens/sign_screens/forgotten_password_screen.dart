import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snulife_internal/ui/widgets/commons/button_widgets.dart';

import '../../../main.dart';
import '../../../router.dart';
import '../../widgets/screen_specified/login_widget.dart';

class ForgottenPasswordPage extends StatefulWidget {
  const ForgottenPasswordPage({super.key});

  @override
  State<ForgottenPasswordPage> createState() => _ForgottenPasswordPageState();
}

class _ForgottenPasswordPageState extends State<ForgottenPasswordPage> {
  final emailController = TextEditingController();
  bool isBtnEnabled = false;
  void Function()? onPressed;

  @override
  void initState() {
    super.initState();
    emailController.addListener(
      () => setState(() {
        isBtnEnabled = emailController.text.isNotEmpty;
      }),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    onPressed = isBtnEnabled
        ? () {
            context.pushNamed(AppRoutePath.confirmPasswordReset);
          }
        : null;

    return Container(
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
          const SizedBox(height: 80),
          AppLargeButton(
            buttonText: '확인',
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
