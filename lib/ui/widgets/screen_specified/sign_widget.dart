import 'package:flutter/material.dart';

import '../../../logics/common_instances.dart';
import '../../../logics/utils/firebase_util.dart';

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
  final FirebaseAuthErrorTypes fieldStatusMessage;
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
        Text(title, style: appFonts.h3),
        const SizedBox(height: 4),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (_) {
            if (type == '이메일') {
              switch (fieldStatusMessage) {
                case FirebaseAuthErrorTypes.invalidEmail:
                  return '올바른 이메일을 입력해주세요';
                case FirebaseAuthErrorTypes.channelError:
                  return '서버 오류가 발생했습니다';
                case FirebaseAuthErrorTypes.invalidCredential:
                  return '이메일을 확인해주세요';
                case FirebaseAuthErrorTypes.userDisabled:
                  return '비활성화된 이메일입니다';
                case FirebaseAuthErrorTypes.networkRequestFailed:
                  return '네트워크 연결을 확인해주세요';
                case FirebaseAuthErrorTypes.unknownError:
                  return '알 수 없는 오류가 발생했습니다';
                case FirebaseAuthErrorTypes.none:
                  return null;
              }
            } else {
              switch (fieldStatusMessage) {
                case FirebaseAuthErrorTypes.invalidCredential:
                  return '비밀번호를 확인해주세요';
                default:
                  return null;
              }
            }
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: appFonts.b2.copyWith(color: appColors.grey4),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: appColors.slBlue),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: appColors.failure),
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
