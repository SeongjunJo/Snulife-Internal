import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snulife_internal/main.dart';
import 'package:snulife_internal/router.dart';

import '../widgets/screen_specified/login_widget.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isAutoLogInTap = false;

  @override
  dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _tryLogIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      // TODO print문 제거 & 에러 핸들링...
      // FirebaseAuthException이 안 잡히면 그냥 e를 전부 잡아서 로그 까는 게 좋을 수 있음
      if (e.code == 'user-not-found') {
        print("user not found");
      } else if (e.code == 'wrong-password') {
        print("wrong password");
      }
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

    Icon checkBox = isAutoLogInTap
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
      body: ListView(
        padding: const EdgeInsets.only(top: 95, left: 20, right: 20),
        children: [
          Text("로그인 해주세요", style: appFonts.h1),
          const SizedBox(height: 60),
          LoginTextField(type: "이메일", controller: emailController),
          const SizedBox(height: 34),
          LoginTextField(type: "비밀번호", controller: passwordController),
          const SizedBox(height: 38),
          GestureDetector(
            onTap: () {
              setState(() {
                isAutoLogInTap = !isAutoLogInTap;
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
          // TODO 아래부터는 디자인 확정 후 반영
          const SizedBox(height: 38),
          Center(
            child: TextButton(
              onPressed: _tryLogIn,
              style: TextButton.styleFrom(
                backgroundColor: appColors.slBlue,
                minimumSize: const Size(300, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: const Text('로그인', style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 38),
          GestureDetector(
            onTap: () {},
            child: const Center(
              child: Text("비밀번호를 잊으셨나요?"),
            ),
          ),
        ],
      ),
    );
  }
}
