import 'package:flutter/material.dart';

import '../../../logics/global_values.dart';

class LoginTextFormField extends StatelessWidget {
  const LoginTextFormField({
    super.key,
    required this.type,
    required this.controller,
    required this.fieldStatusMessage,
    this.isForgottenPasswordField = false,
  });

  final String type;
  final TextEditingController controller;
  final FirebaseAuthErrors fieldStatusMessage;
  final bool isForgottenPasswordField;

  @override
  Widget build(BuildContext context) {
    final String title = type == '이메일' ? '이메일' : '비밀번호';
    final String hint = type == '비밀번호'
        ? '비밀번호를 입력해주세요'
        : isForgottenPasswordField
            ? '가입시 사용한 이메일을 입력해주세요'
            : '이메일을 입력해주세요';
    final TextInputType keyboardType = type == '이메일'
        ? TextInputType.emailAddress
        : TextInputType.visiblePassword;
    final TextInputAction inputAction =
        (type == '비밀번호') || isForgottenPasswordField
            ? TextInputAction.done
            : TextInputAction.next;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: appFonts.loginFieldTitle),
        const SizedBox(height: 4),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (_) {
            switch (fieldStatusMessage) {
              case FirebaseAuthErrors.invalidEmail:
                return '올바른 이메일을 입력해주세요';
              case FirebaseAuthErrors.userNotFound:
                return '등록되지 않은 이메일입니다';
              case FirebaseAuthErrors.unknownError:
                return '알 수 없는 오류가 발생했습니다';
              case FirebaseAuthErrors.none:
                return null;
            }
          },
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
          obscureText: type == '비밀번호',
          keyboardType: keyboardType,
          textInputAction: inputAction,
          controller: controller,
        ),
      ],
    );
  }
}
