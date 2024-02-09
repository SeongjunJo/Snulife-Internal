import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snulife_internal/router.dart';
import 'package:snulife_internal/ui/widgets/commons/button_widgets.dart';

import '../../../logics/global_values.dart';
import '../../widgets/screen_specified/login_widget.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isBtnEnable = false;
  FirebaseAuthErrors _fieldStatus = FirebaseAuthErrors.none;
  void Function()? _onPressed;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(
      () => setState(() {
        _isBtnEnable = _emailController.text.isNotEmpty &
            _passwordController.text.isNotEmpty;
      }),
    );
    _passwordController.addListener(
      () => setState(() {
        _isBtnEnable = _emailController.text.isNotEmpty &
            _passwordController.text.isNotEmpty;
      }),
    );
  }

  @override
  dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _tryLogIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          _fieldStatus = FirebaseAuthErrors.invalidEmail;
        case 'user-disabled':
          _fieldStatus = FirebaseAuthErrors.userDisabled;
        case 'channel-error':
          _fieldStatus = FirebaseAuthErrors.channelError;
        case 'invalid-credential':
          _fieldStatus = FirebaseAuthErrors.invalidCredential;
        case 'network-request-failed':
          _fieldStatus = FirebaseAuthErrors.networkRequestFailed;
        default:
          _fieldStatus = FirebaseAuthErrors.unknownError;
      }
      setState(() {});
      return;
    }
    setState(() => _fieldStatus = FirebaseAuthErrors.none);
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        context.goNamed(AppRoutePath.home);
      }
    });

    _onPressed = _isBtnEnable ? () => _tryLogIn() : null;

    return Scaffold(
      backgroundColor: appColors.white,
      body: ListView(
        padding: const EdgeInsets.only(top: 95, left: 20, right: 20),
        children: [
          Text("로그인 해주세요", style: appFonts.signScreensTitle),
          const SizedBox(height: 60),
          LoginTextFormField(
            type: "이메일",
            controller: _emailController,
            fieldStatusMessage: _fieldStatus,
          ),
          const SizedBox(height: 34),
          LoginTextFormField(
            type: "비밀번호",
            controller: _passwordController,
            fieldStatusMessage: _fieldStatus,
          ),
          const SizedBox(height: 60),
          AppLargeButton(buttonText: '로그인', onPressed: _onPressed),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              context.pushNamed(AppRoutePath.forgottenPassword);
            },
            child: Center(
              child: Text("비밀번호를 잊으셨나요?",
                  style: appFonts.loginForgotPasswordAskText),
            ),
          ),
        ],
      ),
    );
  }
}
