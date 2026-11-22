import 'package:educ_core/data/models/profile.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/helpers.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_student/core/assets.dart';
import 'package:educ_student/core/routes.dart';
import 'package:educ_student/screens/auth/auth_cubit.dart';
import 'package:educ_student/screens/profile/profile_cubit.dart';
import 'package:educ_student/screens/profile/profile_button.dart';
import 'package:educ_student/screens/profile/stats_tile.dart';
import 'package:educ_student/widgets/avatar_choice.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          "profile".tr(),
          style: Omnes.w700
              .getStyle(fontSize: 24, color: context.colorScheme.primary),
        ),
        actions: [
          IconButton(
            onPressed: () => context
                .read<AuthCubit>()
                .signOut(context),
            style: TextButton.styleFrom(
                foregroundColor: context.colorScheme.error),
            icon: const Icon(Icons.logout),
            tooltip: 'logout'.tr(),
          ),
        ],
        // actions: [
        //   IconButton(
        //     onPressed: () => context.pushNamed(Routes.SETTINGS),
        //     icon: SvgPicture.asset(
        //       Svgs.settings,
        //       colorFilter: context.colorScheme.primary.toColorFilter(),
        //     ),
        //   )
        // ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final cubit = context.read<ProfileCubit>();
          final profile = cubit.profile;
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (profile == null) {
            return const SizedBox.shrink();
          }
          return RefreshIndicator(
            onRefresh:() =>  cubit.fetch(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAvatarBar(context, profile),
                  const SizedBox(height: 24.0),
                  ..._buildStatTiles(context, profile),
                  const SizedBox(height: 24.0),
                  ..._buildProfileButtons(context),
                  // const SizedBox(height: 24.0),
                  // _buildLanguageDropDown(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildProfileButtons(BuildContext context) {
    return [
      ProfileButton(
        onTap: () => context.pushNamed(Routes.SETTINGS),
        title: "settings".tr(),
        iconPath: Svgs.settings,
      ),
      const SizedBox(height: 16.0),
      ProfileButton(
        onTap: () => context.pushNamed(Routes.ACHIEVEMENTS),
        title: "achievements".tr(),
        iconPath: Svgs.medalStar,
      ),

      const SizedBox(height: 16.0),
      ProfileButton(
        onTap: () => context.pushNamed(Routes.BOOKMARKS),
        title: "bookmarks".tr(),
        iconPath: Svgs.bookmarkBroken,
      ),
      const SizedBox(height: 16.0),
      ProfileButton(
        onTap: () => context.pushNamed(Routes.CERTIFICATES),
        title: "certificates".tr(),
        iconPath: Svgs.certificate,
      ),
      const SizedBox(height: 16.0),
      ProfileButton(
        onTap: () => context.pushNamed(Routes.HELP_CENTER),
        title: "help".tr(),
        iconPath: Svgs.infoSquare,
      ),
    ];
  }

  Row _buildAvatarBar(BuildContext context, Profile profile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: AvatarChoice(
            url: profile.avatarFileName,
            borderWidth: 2,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${profile.firstName} ${profile.lastName}",
                style: Omnes.w700.getStyle(fontSize: 16),
              ),
              const SizedBox(height: 16.0),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTopStatsItem(
                      context,
                      "my_posts".tr(),
                      profile.postsCount,
                    ),
                    _buildVerticalDivider(context),
                    _buildTopStatsItem(
                      context,
                      "followers".tr(),
                      profile.followersCount,
                    ),
                    _buildVerticalDivider(context),
                    _buildTopStatsItem(
                      context,
                      "following".tr(),
                      profile.followingsCount,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(BuildContext context) {
    return VerticalDivider(
      width: 16,
      thickness: 1,
      indent: 2,
      endIndent: 2,
      color: context.colorScheme.outline.withValues(alpha: 0.1),
    );
  }

  Widget _buildTopStatsItem(BuildContext context, String title, int value) {
    final formattedValue = formatIntegerRecord(value);
    return Flexible(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(
                text: formattedValue.number,
                children: [
                  TextSpan(
                    text: " ${formattedValue.unit}",
                    style: const TextStyle(fontFamily: Omnes.fontFamily),
                  ),
                ],
              ),
              style: Montserrat.w500.getStyle(
                fontSize: 16,
                color: context.colorScheme.onSurface,
              ),
            ),
            Text(
              title,
              style: Omnes.w400.getStyle(
                fontSize: 16,
                color: context.colorScheme.onSurface
                    .alphaBlend(context.colorScheme.surface, 0.5),
              ),
            ),
          ]),
    );
  }

  List<Widget> _buildStatTiles(BuildContext context, Profile profile) {
    final formattedStreak = formatDaysRecord(profile.streak);
    return [
      StatsTile(
        title: Text("streak".tr()),
        iconPath: Svgs.thunder,
        value: Text.rich(
          TextSpan(
            text: formattedStreak.number,
            children: [
              TextSpan(
                text: " ${formattedStreak.unit}",
                style: const TextStyle(fontFamily: Omnes.fontFamily),
              )
            ],
          ),
        ),
      ),
      const SizedBox(height: 16.0),
      StatsTile(
        title: Text("level".tr()),
        iconPath: Svgs.star,
        value: Text(
          profile.rank,
        ),
      ),
      const SizedBox(height: 16.0),
      StatsTile(
        title: Text("points".tr()),
        iconPath: Svgs.achievementCup,
        value: Text(
          "${profile.totalScore}",
        ),
      ),
    ];
  }
}

// void _tempAdvancedQuiz(BuildContext context) async {
//   final questionRepository = QuestionRepository();
//
//   const id = "7";
//
//   final result = await questionRepository.getAdvancedQuestions(
//     id,
//   );
//
//   result.fold(
//     (data) {
//       final quiz = Quiz.advanced(questions: data);
//       context.pushNamed(
//         Routes.ADVANCED_QUIZ,
//         extra: quiz.toMap(),
//         queryParameters: {"rootCollectionId": id},
//       );
//     },
//     (failure) {
//       Logger.error("Error fetching advanced questions", failure);
//     },
//   );
// }
