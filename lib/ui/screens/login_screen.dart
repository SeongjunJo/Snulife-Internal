import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:snulife_internal/logics/providers/login_state.dart';

class LogInPage extends StatelessWidget {
  const LogInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Log In"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Consumer<LogInState>(
          builder: (context, logInState, _) =>
              LoginForm(isLoggedIn: logInState.isLoggedIn),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  final bool isLoggedIn;

  const LoginForm({super.key, required this.isLoggedIn});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void _signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      // TODO print문 제거 & 에러 핸들링...
      if (e.code == 'user-not-found') {
        print("user not found");
      } else if (e.code == 'wrong-password') {
        print("wrong password");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Email',
          ),
          keyboardType: TextInputType.emailAddress,
          controller: emailController,
        ),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Password',
          ),
          obscureText: true,
          controller: passwordController,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            _signIn();
            if (widget.isLoggedIn) {
              context.go('/home');
            }
          },
          child: const Text('Log In'),
        ),
      ],
    );
  }
}
