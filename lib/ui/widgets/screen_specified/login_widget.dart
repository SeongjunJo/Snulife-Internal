import 'package:flutter/material.dart';

import '../../../main.dart';

class LoginTextField extends StatelessWidget {
  const LoginTextField({
    super.key,
    required this.type,
    required this.controller,
  });

  final String type;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final String title = type == '이메일' ? '이메일' : '비밀번호';
    final String hint = type == '이메일' ? '이메일을 입력해주세요' : '비밀번호를 입력해주세요';
    final TextInputAction action =
        type == '이메일' ? TextInputAction.next : TextInputAction.done;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: appFonts.loginFieldTitle),
        const SizedBox(height: 4),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: appFonts.loginFieldHint,
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: appColors.slBlue),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: appColors.red),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: action,
          controller: controller,
        ),
      ],
    );
  }
}