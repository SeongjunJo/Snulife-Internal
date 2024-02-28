import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../logics/common_instances.dart';
import 'button_widgets.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onPressed,
  });

  final String title;
  final String content;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: appColors.white,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: appFonts.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: appFonts.b2.copyWith(color: appColors.grey5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                AppExpandedButton(
                  buttonText: "취소",
                  onPressed: () => Navigator.pop(context),
                  // context.pop()은 GoRouter의 pop이어서 홈 화면으로 나가짐
                  isCancelButton: true,
                ),
                const SizedBox(width: 8),
                AppExpandedButton(
                  buttonText: "확정",
                  onPressed: onPressed,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BottomModal extends StatefulWidget {
  const BottomModal({
    super.key,
    required this.onFirstTap,
    required this.onSecondTap,
    required this.onPressed,
  });

  final Function() onFirstTap;
  final Function() onSecondTap;
  final Function()? onPressed;

  @override
  State<BottomModal> createState() => _BottomModalState();
}

class _BottomModalState extends State<BottomModal> {
  int? _modalIndex; // 모달의 결석/지각 체크 박스 인덱스: null이면 선택 안 함, 1이면 결석, 2면 지각

  @override
  void initState() {
    super.initState();
    _modalIndex = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: appColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        height: 312,
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 22),
              Text("지각/결석 여부를 선택해주세요.", style: appFonts.tm),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => setState(() {
                  _modalIndex = 0;
                  widget.onFirstTap();
                }),
                child: SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("결석",
                          style: appFonts.h3.copyWith(color: appColors.grey8)),
                      Image.asset(
                        "assets/images/icon_check.png",
                        color: _modalIndex == 0
                            ? appColors.slBlue
                            : appColors.grey3,
                        width: 34,
                        height: 34,
                      ),
                    ],
                  ),
                ),
              ),
              Container(height: 1, color: appColors.grey3),
              GestureDetector(
                onTap: () => setState(() {
                  _modalIndex = 1;
                  widget.onSecondTap();
                }),
                child: SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("지각",
                          style: appFonts.h3.copyWith(color: appColors.grey8)),
                      Image.asset(
                        "assets/images/icon_check.png",
                        color: _modalIndex == 1
                            ? appColors.slBlue
                            : appColors.grey3,
                        width: 34,
                        height: 34,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '신청 후에는 서기만 출결 변경이 가능해요.',
                style: appFonts.c2.copyWith(color: appColors.grey5),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppExpandedButton(
                    buttonText: '취소',
                    onPressed: () => context.pop(),
                    isCancelButton: true,
                  ),
                  const SizedBox(width: 8),
                  AppExpandedButton(
                      buttonText: '확정', onPressed: widget.onPressed),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
