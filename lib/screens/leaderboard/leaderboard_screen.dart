import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_student/core/assets.dart';
import 'package:educ_student/screens/profile/profile_cubit.dart';
import 'package:educ_student/screens/leaderboard/friends_leaderboard_tab.dart';
import 'package:educ_student/screens/leaderboard/global_leaderboard_tab.dart';
import 'package:educ_student/widgets/guest_mode_overlay.dart';
import 'package:educ_student/widgets/responsive_layout.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GuestRestrictedOverlay(
      title: "guest_mode_leaderboard_title".tr(),
      description: "guest_mode_leaderboard_description".tr(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            "leaderboard".tr(),
            style: Omnes.w700
                .getStyle(fontSize: 24, color: context.colorScheme.primary),
          ),
          actions: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 16.0),
              child: _buildUserTotalScore(context),
            ),
          ],
        ),
        body: DefaultTabController(
          length: 2,
          animationDuration: Duration.zero,
          child: Column(
            children: [
              Container(
                color: context.theme.scaffoldBackgroundColor,
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: Omnes.w700.getStyle(fontSize: 16.0),
                  unselectedLabelColor: context.colorScheme.primary,
                  tabs: [
                    Tab(text: "leaderboard_global".tr()),
                    Tab(text: "leaderboard_friends".tr()),
                  ],
                ),
              ),
              const Expanded(
                child: ResponsiveLayout(
                  child: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      GlobalLeaderboardTab(),
                      FriendsLeaderboardTab(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTotalScore(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final cubit = context.read<ProfileCubit>();
        if (state is ProfileLoaded) {
          return Row(
            children: [
              Text(
                cubit.profile?.totalScore.toString() ?? "0",
                style: Omnes.w700.getStyle(
                  fontSize: 18.0,
                  color: context.colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 8.0),
              SvgPicture.asset(
                Svgs.achievementCup,
                colorFilter: context.colorScheme.tertiary.toColorFilter(),
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
