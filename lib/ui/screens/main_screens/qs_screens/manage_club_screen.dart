import 'package:flutter/cupertino.dart';
import 'package:snulife_internal/ui/screens/main_screens/qs_screens/sub_screens/manage_people_screen.dart';
import 'package:snulife_internal/ui/screens/main_screens/qs_screens/sub_screens/set_next_meeting.dart';
import 'package:snulife_internal/ui/screens/main_screens/qs_screens/sub_screens/set_rest_teem_meeting_screen.dart';

import '../../../../logics/common_instances.dart';
import '../../../widgets/commons/button_widgets.dart';

class ManageClubPage extends StatefulWidget {
  const ManageClubPage({super.key, required this.currentSemester});

  final String currentSemester;

  @override
  State<ManageClubPage> createState() => _ManageClubPageState();
}

class _ManageClubPageState extends State<ManageClubPage> {
  int _tabTagIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: appColors.grey0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              AppTabTag(
                title: '일정 관리',
                isTurnedOn: _tabTagIndex == 1,
                onPressed: () => setState(() => _tabTagIndex = 1),
              ),
              const SizedBox(width: 8),
              AppTabTag(
                title: '회의일 지정',
                isTurnedOn: _tabTagIndex == 2,
                onPressed: () => setState(() => _tabTagIndex = 2),
              ),
              const SizedBox(width: 8),
              AppTabTag(
                title: '동아리원 관리',
                isTurnedOn: _tabTagIndex == 3,
                onPressed: () => setState(() => _tabTagIndex = 3),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_tabTagIndex == 1)
            SetRestOrTeemMeetingPage(currentSemester: widget.currentSemester)
          else if (_tabTagIndex == 2)
            SetNextMeeting(currentSemester: widget.currentSemester)
          else
            const ManagePeoplePage(),
        ],
      ),
    );
  }
}
