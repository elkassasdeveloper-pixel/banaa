import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/widgets/error_message_card.dart';
import 'package:educ_student/core/assets.dart';
import 'package:educ_student/screens/other/achievements_cubit.dart';
import 'package:educ_student/widgets/achievement_tile.dart';
import 'package:educ_student/widgets/back_arrow_button.dart';
import 'package:educ_student/widgets/gradiant_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AchievementsCubit(),
      child: GradiantScreen(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              "back".tr(),
              style: Omnes.w400.getStyle(color: context.colorScheme.primary, fontSize: 18.0),
            ),
            leading: const BackArrowButton(),
          ),
          body: _buildList(context),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return BlocBuilder<AchievementsCubit, AchievementsState>(
      builder: (context, state) {
        final cubit = context.read<AchievementsCubit>();
        final achievements = cubit.achievements;

        if (state is AchievementsLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is AchievementsError) {
          return Center(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ErrorMessageCard.failure(
              failure: state.failure,
              onRetry: cubit.fetch,
            ),
          ));
        } else if (achievements == null) {
          return Center(
            child: Text("errors.empty_data".tr()),
          );
        } else {
          if (achievements.isEmpty) {
            return Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  Svgs.landscape,
                  fit: BoxFit.fill,
                ),
                Center(
                  child: Text(
                    "no achievements yet !".tr(),
                    style: Omnes.w600.getStyle(color: context.colorScheme.primary, fontSize: 18.0),
                  ),
                ),
              ],
            );
          } else {
            return ListView.separated(
              itemCount: achievements.length,
              padding: const EdgeInsets.all(16.0),
              itemBuilder: (context, index) {
                final item = achievements[index];
                return AchievementTile(achievement: item);
              },
              separatorBuilder: (context, index) {
                return const SizedBox(
                  height: 16.0,
                );
              },
            );
          }
        }
      },
    );
  }
}
