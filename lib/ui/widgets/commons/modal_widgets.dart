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
    required this.height,
    required this.title,
    this.hintText,
    this.canScroll = false,
    required this.tapTexts,
    required this.onTapsPressed,
    required this.onBtnPressed,
  });

  final double height;
  final String title;
  final String? hintText;
  final bool canScroll;
  final List<String> tapTexts;
  final List<Function()> onTapsPressed;
  final Function()? onBtnPressed;

  @override
  State<BottomModal> createState() => _BottomModalState();
}

class _BottomModalState extends State<BottomModal> {
  int? _modalIndex; // 모달의 체크 박스 인덱스: null이면 선택 안 함
  late final _scrollController;

  @override
  void initState() {
    super.initState();
    _modalIndex = null;
    _scrollController = ScrollController();
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
        height: widget.height,
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 24),
              Text(widget.title, style: appFonts.tm),
              const SizedBox(height: 24),
              Expanded(
                child: RawScrollbar(
                  controller: _scrollController,
                  thumbColor: appColors.grey4,
                  thickness: 5,
                  thumbVisibility: true,
                  radius: const Radius.circular(30),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: widget.canScroll ? 18 : 0),
                    child: ListView.separated(
                      shrinkWrap: true,
                      controller: _scrollController,
                      physics: widget.canScroll
                          ? const AlwaysScrollableScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      itemCount: widget.tapTexts.length,
                      itemBuilder: (context, index) =>
                          buildGestureDetector(index),
                      separatorBuilder: (context, index) =>
                          Container(height: 1, color: appColors.grey3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              widget.hintText != null
                  ? Text(
                      widget.hintText!,
                      style: appFonts.c2.copyWith(color: appColors.grey5),
                    )
                  : const SizedBox(height: 0),
              SizedBox(height: widget.hintText != null ? 16 : 12),
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
                      buttonText: '확인', onPressed: widget.onBtnPressed),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector buildGestureDetector(int index) {
    return GestureDetector(
      onTap: () => setState(() {
        _modalIndex = index;
        widget.onTapsPressed[index]();
      }),
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.tapTexts[index],
                style: appFonts.h3.copyWith(color: appColors.grey8)),
            Image.asset(
              "assets/images/icon_check.png",
              color: _modalIndex == index ? appColors.slBlue : appColors.grey3,
              width: 34,
              height: 34,
            ),
          ],
        ),
      ),
    );
  }
}
