import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:snulife_internal/logics/common_instances.dart';
import 'package:snulife_internal/ui/widgets/commons/button_widgets.dart';
import 'package:snulife_internal/ui/widgets/commons/modal_widgets.dart';

import '../../../../../logics/providers/firebase_states.dart';
import '../../../../../logics/utils/map_util.dart';
import '../../../../widgets/commons/snackbar_widget.dart';

class ManagePeoplePage extends StatefulWidget {
  const ManagePeoplePage({super.key});

  @override
  State<ManagePeoplePage> createState() => _ManagePeoplePageState();
}

class _ManagePeoplePageState extends State<ManagePeoplePage> {
  // 여기서 setState 쓰면 안 됨 => ValueNotifier로 변경
  late final List userList;
  late final List restUserList;
  final updatedCount = ValueNotifier(0); // Change Notifier 안 쓰고 counter로 대체
  final List<Map<String, dynamic>> updatedInfoList = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: firebaseInstance.db
          .collection('users')
          .withConverter(
            fromFirestore: UserInfo.fromFirestore,
            toFirestore: (UserInfo userInfo, _) => userInfo.toFirestore(),
          )
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
        if (streamSnapshot.hasData) {
          final List<UserInfo> peopleInfoList = streamSnapshot.data!.docs
              .map((doc) => doc.data())
              .toList(growable: false)
              .cast<UserInfo>()
            ..sort((a, b) => a.name.compareTo(b.name));

          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: peopleInfoList.length,
                      itemBuilder: (context, index) {
                        ValueNotifier createInfoNotifier(content) =>
                            ValueNotifier(
                                {'content': content, 'hasUpdated': false});

                        final team =
                            createInfoNotifier(peopleInfoList[index].team);
                        final grade =
                            createInfoNotifier(peopleInfoList[index].isAlum
                                ? '알럼나이'
                                : peopleInfoList[index].isSenior
                                    ? '시니어'
                                    : '주니어');
                        final position =
                            createInfoNotifier(peopleInfoList[index].position);
                        final isRest = createInfoNotifier(
                            peopleInfoList[index].isRest ? '휴면' : '활동');

                        return Row(
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
                                _buildInfoTag(
                                    peopleInfoList[index].name,
                                    'team',
                                    team,
                                    ['개발팀', '디자인팀', '전략마케팅팀'],
                                    false),
                                const SizedBox(width: 10),
                                _buildInfoTag(
                                    peopleInfoList[index].name,
                                    'grade',
                                    grade,
                                    ['알럼나이', '시니어', '주니어'],
                                    false),
                                const SizedBox(width: 10),
                                _buildInfoTag(
                                    peopleInfoList[index].name,
                                    'position',
                                    position,
                                    ['대표', '부대표', '팀장', '팀원'],
                                    true),
                                const SizedBox(width: 10),
                                _buildInfoTag(
                                    peopleInfoList[index].name,
                                    'isRest',
                                    isRest,
                                    ['활동', '휴면', '탈퇴'],
                                    false),
                              ],
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 20),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => _FreshManBottomModal(
                              peopleInfoList: peopleInfoList),
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
                    if (peopleInfoList.length > 9)
                      Column(
                        children: [
                          const SizedBox(height: 24),
                          _buildButton(),
                        ],
                      ),
                  ],
                ),
              ),
              if (peopleInfoList.length <= 9) _buildButton(),
            ],
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  ValueListenableBuilder _buildInfoTag(
      userName, key, ValueNotifier info, tabTexts, canScroll) {
    final originInfo = info.value['content'];
    String selectedOption = '';
    bool hasUpdated = false;
    int localUpdatedCount = 0;
    final List<Function()> onTabsPressed = [];
    for (final text in tabTexts) {
      onTabsPressed.add(() => selectedOption = text);
    }

    return ValueListenableBuilder(
      valueListenable: info,
      builder: (context, value, _) {
        return GestureDetector(
          onTap: () {
            showModalBottomSheet(
              useRootNavigator: false,
              context: context,
              builder: (context) => SelectOnlyBottomModal(
                height: 400,
                canScroll: canScroll,
                title: '변경 유형을 선택해주세요.',
                hintText: '선택 후 변경 확정을 해야 변경사항이 반영돼요.',
                tapTexts: tabTexts,
                onTapsPressed: onTabsPressed,
                onBtnPressed: () {
                  context.pop();
                  if (selectedOption.isNotEmpty) {
                    hasUpdated = originInfo != selectedOption;
                    info.value = {
                      'content': selectedOption,
                      'hasUpdated': hasUpdated,
                    };
                    final isGrade = key == 'grade'; // key와 type이 다를 때 처리
                    final isRest = key == 'isRest';
                    bool isAlum = false;
                    bool isSenior = false;
                    bool? isRestUser = false;
                    switch (selectedOption) {
                      case '알럼나이':
                        isAlum = true;
                        isSenior = false;
                      case '시니어':
                        isAlum = false;
                        isSenior = true;
                      case '탈퇴':
                        isRestUser = null;
                      case '휴면':
                        isRestUser = true;
                    }

                    updatedInfoList.removeWhere((element) =>
                        element['name'] == userName &&
                        element.containsKey(isGrade ? 'isAlum' : key));
                    if (hasUpdated) {
                      localUpdatedCount++;
                      updatedCount.value++;
                      if (isGrade) {
                        updatedInfoList.add({
                          'name': userName,
                          'isAlum': isAlum,
                          'isSenior': isSenior,
                        });
                      } else if (isRest) {
                        updatedInfoList
                            .add({'name': userName, key: isRestUser});
                      } else {
                        updatedInfoList
                            .add({'name': userName, key: selectedOption});
                      }
                    } else {
                      updatedCount.value -= localUpdatedCount;
                      localUpdatedCount = 0;
                    }
                  }
                },
              ),
            );
          },
          child: InfoTag(
            info: info.value['content'],
            isTurnedOn: info.value['hasUpdated'],
          ),
        );
      },
    );
  }

  Column _buildButton() {
    return Column(
      children: [
        ValueListenableBuilder(
          valueListenable: updatedCount,
          builder: (context, value, _) => Row(
            children: [
              AppExpandedButton(
                buttonText: '변경 확정',
                onPressed: updatedCount.value != 0
                    ? () {
                        showDialog(
                          useRootNavigator: false,
                          context: context,
                          builder: (context) => ConfirmDialog(
                            title: '동아리원 관리 변경 내용을\n확정하시겠어요?',
                            content: '변경 사항이 곧바로 반영되니\n꼭 확인 뒤에 확정해주세요.',
                            onPressed: () async {
                              await firestoreWriter
                                  .updatePeopleInfo(updatedInfoList);

                              if (!context.mounted) return;
                              updatedCount.value = 0;
                              updatedInfoList.clear();
                              context.pop();
                              AppSnackBar.showFlushBar(
                                  context, '변경되었습니다.', 10, true);
                            },
                          ),
                        );
                      }
                    : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
      ],
    );
  }
}

class _FreshManBottomModal extends StatefulWidget {
  const _FreshManBottomModal({required this.peopleInfoList});

  final List<UserInfo> peopleInfoList;

  @override
  State<_FreshManBottomModal> createState() => _FreshManBottomModalState();
}

class _FreshManBottomModalState extends State<_FreshManBottomModal> {
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
                                isRest: false,
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
