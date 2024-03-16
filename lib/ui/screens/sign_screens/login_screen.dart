import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snulife_internal/router.dart';
import 'package:snulife_internal/ui/widgets/commons/button_widgets.dart';

import '../../../logics/common_instances.dart';
import '../../../logics/utils/firebase_util.dart';
import '../../widgets/screen_specified/sign_widget.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key, required this.isLoggedIn});

  final bool isLoggedIn;

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isBtnEnable = false;
  FirebaseAuthErrorTypes _fieldStatus = FirebaseAuthErrorTypes.none;
  void Function()? _onPressed;
  bool canPop = false;

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
    showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) => PopScope(
        canPop: canPop,
        onPopInvoked: (bool didPop) {
          if (didPop) {
            setState(() => canPop = false);
          }
        },
        child: Scaffold(
          body: Container(
            color: appColors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("로그인 중...",
                      style: appFonts.h1.copyWith(color: appColors.subBlue1)),
                  const SizedBox(height: 20),
                  CircularProgressIndicator(color: appColors.subBlue1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      _fieldStatus = switch (e.code) {
        'invalid-email' => _fieldStatus = FirebaseAuthErrorTypes.invalidEmail,
        'user-disabled' => _fieldStatus = FirebaseAuthErrorTypes.userDisabled,
        'channel-error' => _fieldStatus = FirebaseAuthErrorTypes.channelError,
        'invalid-credential' => _fieldStatus =
            FirebaseAuthErrorTypes.invalidCredential,
        'network-request-failed' => _fieldStatus =
            FirebaseAuthErrorTypes.networkRequestFailed,
        'too-many-requests' => _fieldStatus =
            FirebaseAuthErrorTypes.tooManyRequests,
        _ => _fieldStatus = FirebaseAuthErrorTypes.unknownError,
      };
      if (!mounted) return;
      setState(() => canPop = true);
      context.pop();
      return;
    }
    setState(() => _fieldStatus = FirebaseAuthErrorTypes.none);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isLoggedIn) {
        context.goNamed(AppRoutePath.home);
      }
    });

    _onPressed = _isBtnEnable ? () => _tryLogIn() : null;

    return Scaffold(
      backgroundColor: appColors.white,
      body: ListView(
        padding: const EdgeInsets.only(top: 95, left: 20, right: 20),
        children: [
          Text("로그인 해주세요.", style: appFonts.h1),
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
          AppExpandedButton(buttonText: '로그인', onPressed: _onPressed),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => context.pushNamed(AppRoutePath.forgottenPassword),
            child: Center(
              child: Text(
                "비밀번호를 잊으셨나요?",
                style: appFonts.b2.copyWith(color: appColors.grey5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
