import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snulife_internal/main.dart';
import 'package:snulife_internal/router.dart';
import 'package:snulife_internal/ui/widgets/commons/button_widgets.dart';

import '../../widgets/screen_specified/login_widget.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isAutoLogInTap = false;

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
      // TODO print문 제거 & 에러 핸들링...
      print("파이어베이스 에러 로그: $e & 에러 코드: ${e.code}");
    } catch (e) {
      print("에러 로그: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        context.goNamed(AppRoutePath.home);
      }
    });

    Icon checkBox = _isAutoLogInTap
        ? Icon(
            Icons.check_circle_rounded,
            color: appColors.slBlue,
            size: 22,
          )
        : Icon(
            Icons.check_circle_outline_rounded,
            color: appColors.grey5,
            size: 22,
          );

    return Scaffold(
      backgroundColor: appColors.white,
      body: ListView(
        padding: const EdgeInsets.only(top: 95, left: 20, right: 20),
        children: [
          Text("로그인 해주세요", style: appFonts.signScreensTitle),
          const SizedBox(height: 60),
          LoginTextField(type: "이메일", controller: _emailController),
          const SizedBox(height: 34),
          LoginTextField(type: "비밀번호", controller: _passwordController),
          const SizedBox(height: 38),
          GestureDetector(
            onTap: () {
              setState(() {
                _isAutoLogInTap = !_isAutoLogInTap;
              });
            },
            child: Row(
              children: [
                checkBox,
                const SizedBox(width: 8),
                Text("자동 로그인", style: appFonts.loginAutoLoginText),
              ],
            ),
          ),
          const SizedBox(height: 38),
          AppLargeButton(buttonText: '로그인', onPressed: _tryLogIn),
          const SizedBox(height: 38),
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
