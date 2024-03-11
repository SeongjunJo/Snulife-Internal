import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snulife_internal/logics/common_instances.dart';
import 'package:snulife_internal/ui/widgets/commons/button_widgets.dart';

import '../../../../../logics/utils/map_util.dart';

class ManagePeoplePage extends StatefulWidget {
  const ManagePeoplePage({super.key});

  @override
  State<ManagePeoplePage> createState() => _ManagePeoplePageState();
}

class _ManagePeoplePageState extends State<ManagePeoplePage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firestoreReader.getPeopleInfo(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          final peopleInfoList = snapshot.data as List<UserInfo>;

          return ListView(
            shrinkWrap: true,
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: peopleInfoList.length,
                itemBuilder: (context, index) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      peopleInfoList[index].name,
                      style: appFonts.b1.copyWith(
                        color: appColors.grey7,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        InfoTag(info: peopleInfoList[index].team),
                        const SizedBox(width: 10),
                        InfoTag(
                          info: peopleInfoList[index].isAlum
                              ? '알럼나이'
                              : (peopleInfoList[index].isSenior
                                  ? '시니어'
                                  : '주니어'),
                        ),
                        const SizedBox(width: 10),
                        InfoTag(info: peopleInfoList[index].position),
                        const SizedBox(width: 10),
                        InfoTag(
                          info: peopleInfoList[index].isRestUser ? '휴면' : '활동',
                        ),
                      ],
                    ),
                  ],
                ),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 20),
              ),
              const SizedBox(height: 25),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (BuildContext context) => _BottomModal(),
                  );
                },
                child: DottedBorder(
                  stackFit: StackFit.passthrough,
                  padding: const EdgeInsets.all(0),
                  color: appColors.grey5,
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(12),
                  dashPattern: const [6, 6],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 20),
                    decoration: const BoxDecoration(color: Colors.transparent),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/icon_plus.png',
                            width: 24, height: 24),
                        const SizedBox(width: 12),
                        Text('신입 추가',
                            style:
                                appFonts.t5.copyWith(color: appColors.grey5)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              AppExpandedButton(
                buttonText: '변경 확정',
                onPressed: () {},
              ),
            ],
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}

class _BottomModal extends StatefulWidget {
  @override
  State<_BottomModal> createState() => _BottomModalState();
}

class _BottomModalState extends State<_BottomModal> {
  final textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: appColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        height: 360,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text('신입 회원의 이름과 기수를 적어주세요.', style: appFonts.tm),
                const SizedBox(height: 12),
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (_) {
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: '예: 홍길동/46',
                    hintStyle: appFonts.b2.copyWith(color: appColors.grey4),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: appColors.slBlue),
                    ),
                    errorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: appColors.failure),
                    ),
                  ),
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.done,
                  controller: textEditingController,
                ),
                const SizedBox(height: 40),
                Text('신입 회원이 속한 팀을 지정해주세요.', style: appFonts.tm),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    InfoTag(info: '개발팀'),
                    SizedBox(width: 10),
                    InfoTag(info: '디자인팀'),
                    SizedBox(width: 10),
                    InfoTag(info: '전략마케팅팀'),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppExpandedButton(
                      buttonText: '취소',
                      onPressed: () => context.pop(),
                      isCancelButton: true,
                    ),
                    const SizedBox(width: 8),
                    AppExpandedButton(buttonText: '확인', onPressed: () {}),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
