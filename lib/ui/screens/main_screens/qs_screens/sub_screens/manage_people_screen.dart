import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:snulife_internal/logics/common_instances.dart';
import 'package:snulife_internal/ui/widgets/commons/button_widgets.dart';

import '../../../../../logics/providers/firebase_states.dart';
import '../../../../../logics/utils/map_util.dart';
import '../../../../widgets/commons/snackbar_widget.dart';

class ManagePeoplePage extends StatefulWidget {
  const ManagePeoplePage({super.key});

  @override
  State<ManagePeoplePage> createState() => _ManagePeoplePageState();
}

class _ManagePeoplePageState extends State<ManagePeoplePage> {
  late final List userList;
  late final List restUserList;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: firebaseInstance.db
          .collection('information')
          .doc('userList')
          .snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot> streamSnapshot) {
        if (streamSnapshot.hasData) {
          return FutureBuilder(
            future: firestoreReader
                .getPeopleInfo(streamSnapshot.data! as DocumentSnapshot<Map?>),
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
                                info: peopleInfoList[index].isRestUser
                                    ? '휴면'
                                    : '활동',
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
                          builder: (context) =>
                              _BottomModal(peopleInfoList: peopleInfoList),
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
                          decoration:
                              const BoxDecoration(color: Colors.transparent),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/images/icon_plus.png',
                                  width: 24, height: 24),
                              const SizedBox(width: 12),
                              Text('신입 추가',
                                  style: appFonts.t5
                                      .copyWith(color: appColors.grey5)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    AppExpandedButton(
                      buttonText: '변경 확정',
                      onPressed: () async {},
                    ),
                  ],
                );
              } else {
                return const SizedBox();
              }
            },
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}

class _BottomModal extends StatefulWidget {
  const _BottomModal({required this.peopleInfoList});

  final List<UserInfo> peopleInfoList;

  @override
  State<_BottomModal> createState() => _BottomModalState();
}

class _BottomModalState extends State<_BottomModal> {
  final textEditingController = TextEditingController();
  late final List<String> nameAndYear;
  int index = 0;
  bool hasError = true;
  bool isConfirmStep = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: appColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        height: !isConfirmStep ? 360 : 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            !isConfirmStep
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Text('신입 회원의 이름과 기수를 적어주세요.', style: appFonts.tm),
                      const SizedBox(height: 12),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (_) {
                          final nameAndYear =
                              textEditingController.text.split('/');

                          if (!textEditingController.text.contains('/') ||
                              !RegExp(r'^[가-힣]+$')
                                  .hasMatch(nameAndYear.first) ||
                              !RegExp(r'^[0-9]+$').hasMatch(nameAndYear.last)) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(() => hasError = true);
                            });
                            return '올바른 형식으로 입력해주세요.';
                          }

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() => hasError = false);
                          });
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: '예: 홍길동/46',
                          hintStyle:
                              appFonts.b2.copyWith(color: appColors.grey4),
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
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => index = 1),
                            child: InfoTag(info: '개발팀', isTurnedOn: index == 1),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => setState(() => index = 2),
                            child:
                                InfoTag(info: '디자인팀', isTurnedOn: index == 2),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => setState(() => index = 3),
                            child:
                                InfoTag(info: '전략마케팅팀', isTurnedOn: index == 3),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  )
                : Column(
                    children: [
                      const SizedBox(height: 24),
                      Text('신입 회원을 추가하시겠어요?', style: appFonts.tm),
                      const SizedBox(height: 34),
                      Text(
                        '${nameAndYear.last}기 ${nameAndYear.first}',
                        style: appFonts.b1.copyWith(
                          color: appColors.grey7,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InfoTag(
                            info: switch (index) {
                              1 => '개발팀',
                              2 => '디자인팀',
                              _ => '전략마케팅팀',
                            },
                          ),
                          const SizedBox(width: 10),
                          const InfoTag(info: '주니어'),
                          const SizedBox(width: 10),
                          const InfoTag(info: '팀원'),
                          const SizedBox(width: 10),
                          const InfoTag(info: '활동'),
                        ],
                      ),
                      const SizedBox(height: 34),
                      Text(
                        '확정 시 동아리원 관리 목록에 즉시 반영됩니다.',
                        style: appFonts.c2.copyWith(color: appColors.grey5),
                      )
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
                    AppExpandedButton(
                      buttonText: !isConfirmStep ? '확인' : '확정',
                      onPressed: !isConfirmStep
                          ? (index != 0 && !hasError)
                              ? () => setState(
                                    () {
                                      isConfirmStep = true;
                                      nameAndYear =
                                          textEditingController.text.split('/');
                                    },
                                  )
                              : null
                          : () async {
                              final newUser = UserInfo(
                                name: nameAndYear.first,
                                year: int.parse(nameAndYear.last),
                                team: switch (index) {
                                  1 => '개발팀',
                                  2 => '디자인팀',
                                  _ => '전략마케팅팀',
                                },
                                position: '팀원',
                                isSenior: false,
                                isAlum: false,
                                promotionCount: 0,
                              );

                              await firestoreWriter.registerNewUser(
                                newUser,
                                context.read<FirebaseStates>().currentSemester,
                                widget.peopleInfoList,
                              );

                              if (!context.mounted) return;
                              context.pop();
                              AppSnackBar.showFlushBar(
                                  context, '추가되었습니다.', 10, true);
                            },
                    ),
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
