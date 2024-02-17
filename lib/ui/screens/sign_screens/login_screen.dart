import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:snulife_internal/logics/providers/firebase_states.dart';
import 'package:snulife_internal/router.dart';
import 'package:snulife_internal/ui/widgets/commons/button_widgets.dart';

import '../../../logics/common_instances.dart';
import '../../../logics/utils/firebase_util.dart';
import '../../widgets/screen_specified/sign_widget.dart';

class LogInPage extends StatelessWidget {
  const LogInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FirebaseStates>(
      builder: (context, firebaseStates, child) => LogInScreen(
        isLoggedIn: firebaseStates.loggedIn,
      ),
    );
  }
}

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key, required this.isLoggedIn});

  final bool isLoggedIn;

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isBtnEnable = false;
  FirebaseAuthErrorTypes _fieldStatus = FirebaseAuthErrorTypes.none;
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
          _fieldStatus = FirebaseAuthErrorTypes.invalidEmail;
        case 'user-disabled':
          _fieldStatus = FirebaseAuthErrorTypes.userDisabled;
        case 'channel-error':
          _fieldStatus = FirebaseAuthErrorTypes.channelError;
        case 'invalid-credential':
          _fieldStatus = FirebaseAuthErrorTypes.invalidCredential;
        case 'network-request-failed':
          _fieldStatus = FirebaseAuthErrorTypes.networkRequestFailed;
        default:
          _fieldStatus = FirebaseAuthErrorTypes.unknownError;
      }
      setState(() {});
      return;
    }
    setState(() => _fieldStatus = FirebaseAuthErrorTypes.none);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.goNamed(AppRoutePath.home);
      });
    }

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
            onTap: () {
              context.pushNamed(AppRoutePath.forgottenPassword);
            },
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
