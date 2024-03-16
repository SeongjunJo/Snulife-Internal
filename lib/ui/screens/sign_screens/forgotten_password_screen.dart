import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snulife_internal/router.dart';
import 'package:snulife_internal/ui/widgets/commons/button_widgets.dart';

import '../../../logics/common_instances.dart';
import '../../../logics/utils/firebase_util.dart';
import '../../widgets/screen_specified/sign_widget.dart';

class ForgottenPasswordPage extends StatefulWidget {
  const ForgottenPasswordPage({super.key});

  @override
  State<ForgottenPasswordPage> createState() => _ForgottenPasswordPageState();
}

class _ForgottenPasswordPageState extends State<ForgottenPasswordPage> {
  final _emailController = TextEditingController();
  bool _isBtnEnable = false;
  FirebaseAuthErrorTypes _fieldStatus = FirebaseAuthErrorTypes.none;
  void Function()? _onPressed;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(
      () => setState(() {
        _isBtnEnable = _emailController.text.isNotEmpty;
      }),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    GoRouter goRouter = GoRouter.of(context);
    _onPressed = _isBtnEnable
        ? () async {
            try {
              await FirebaseAuth.instance
                  .sendPasswordResetEmail(email: _emailController.text);
            } on FirebaseAuthException catch (e) {
              _fieldStatus = switch (e.code) {
                'invalid-email' => _fieldStatus =
                    FirebaseAuthErrorTypes.invalidEmail,
                'network-request-failed' => _fieldStatus =
                    FirebaseAuthErrorTypes.networkRequestFailed,
                _ => _fieldStatus = FirebaseAuthErrorTypes.unknownError,
              };
              setState(() {});
              return;
            }
            setState(() => _fieldStatus = FirebaseAuthErrorTypes.none);
            goRouter.pushReplacementNamed(AppRoutePath.confirmPasswordReset);
          }
        : null;

    return Container(
      padding: const EdgeInsets.only(top: 45, left: 20, right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("이메일을 입력해주세요.", style: appFonts.h1),
              const SizedBox(height: 48),
              LoginTextFormField(
                type: "이메일",
                controller: _emailController,
                fieldStatusMessage: _fieldStatus,
                isForgottenPasswordField: true,
              ),
            ],
          ),
          Column(
            children: [
              Row(
                children: [
                  AppExpandedButton(
                    buttonText: '확인',
                    onPressed: _onPressed,
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ],
      ),
    );
  }
}
