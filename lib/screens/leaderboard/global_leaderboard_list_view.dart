import 'package:educ_core/educ_core.dart';
import 'package:educ_core/widgets/error_message_card.dart';
import 'package:educ_student/screens/leaderboard/global_leaderboard_cubit.dart';
import 'package:educ_student/screens/leaderboard/leaderboard_list_view.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GlobalLeaderboardListView extends StatelessWidget {
  const GlobalLeaderboardListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GlobalLeaderboardCubit, GlobalLeaderboardState>(
      builder: (context, state) {
        final cubit = context.read<GlobalLeaderboardCubit>();
        if (state is GlobalLeaderboardLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is GlobalLeaderboardError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ErrorMessageCard.failure(
                failure: state.failure,
                onRetry: cubit.fetchCurrentLeaderboard,
              ),
            ),
          );
        }
        final entries = cubit.entries.sortedByCompare(
          (element) => element.score,
          (a, b) => b - a,
        );

        if (entries.isEmpty) {
          return Center(
            child: Text("errors.empty_data".tr()),
          );
        }

        return LeaderboardListView(
          items: entries,
          scrollController: cubit.leaderboardScrollController,
          highlightedEntryKey: cubit.highlightedEntryKey,
        );
      },
    );
  }
}
