import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_student/screens/leaderboard/friends_leaderboard_cubit.dart';
import 'package:educ_student/screens/leaderboard/collections_list_view.dart';
import 'package:educ_student/screens/leaderboard/friends_leaderboard_list_view.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FriendsLeaderboardTab extends StatelessWidget {
  const FriendsLeaderboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FriendsLeaderboardCubit>();

    return RefreshIndicator(
      onRefresh: () => cubit.fetch(languageCode: context.locale.languageCode),
      child: BlocBuilder<FriendsLeaderboardCubit, FriendsLeaderboardState>(
        builder: (context, state) {
          return Column(
            children: [
              const CollectionsListView(),
              Text(
                cubit.currentCollectionName,
                textAlign: TextAlign.center,
                style: Omnes.w700.getStyle(
                  fontSize: 24,
                  color: context.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8.0),
              Expanded(
                child: SingleChildScrollView(
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
                      const FriendsLeaderboardListView(),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
