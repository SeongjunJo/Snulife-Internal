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
            fieldStatusMessage: FirebaseAuthErrors.none,
          ),
          const SizedBox(height: 34),
          LoginTextFormField(
            type: "비밀번호",
            controller: _passwordController,
            fieldStatusMessage: FirebaseAuthErrors.none,
          ),
          const SizedBox(height: 60),
          AppLargeButton(buttonText: '로그인', onPressed: _tryLogIn),
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
