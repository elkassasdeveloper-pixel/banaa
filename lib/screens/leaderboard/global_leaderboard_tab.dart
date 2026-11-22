import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_student/screens/leaderboard/global_leaderboard_cubit.dart';
import 'package:educ_student/screens/leaderboard/global_leaderboard_list_view.dart';
import 'package:educ_student/screens/leaderboard/leagues_list_view.dart';
import 'package:educ_student/screens/main_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GlobalLeaderboardTab extends StatelessWidget {
  const GlobalLeaderboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GlobalLeaderboardCubit>();
    if (!cubit.showAssistantBefore) {
      context.assistant.setEvent(14);
      context.assistant.start();
      cubit.showAssistantBefore = true;
    }
    return RefreshIndicator(
      onRefresh: cubit.fetch,
      child: BlocBuilder<GlobalLeaderboardCubit, GlobalLeaderboardState>(
        builder: (context, state) {
          return Column(
            children: [
              const LeaguesListview(),
              Text(
                cubit.currentLeagueName,
                textAlign: TextAlign.center,
                style: Omnes.w700.getStyle(fontSize: 24, color: context.colorScheme.primary),
              ),
              const SizedBox(height: 8.0),
              Expanded(
                child: SingleChildScrollView(
                  // controller: cubit.leaderboardScrollController,
                  child: Column(
                    children: [
                      const SizedBox(height: 8.0),
                      Text(
                        "top_10".tr(),
                        textAlign: TextAlign.center,
                        style: Omnes.w400.getStyle(
                          fontSize: 24,
                          color: context.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      const GlobalLeaderboardListView(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
