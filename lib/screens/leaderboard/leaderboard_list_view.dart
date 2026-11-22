import 'package:educ_core/data/models/leaderboard_entry.dart';
import 'package:educ_core/services/dio_helper.dart';
import 'package:educ_student/screens/leaderboard/leaderboard_tile.dart';
import 'package:material_ui/material_ui.dart';

class LeaderboardListView extends StatelessWidget {
  final List<LeaderboardEntry> items;
  final ScrollController? scrollController;
  final GlobalKey? highlightedEntryKey;

  const LeaderboardListView({
    super.key,
    required this.items,
    this.scrollController,
    this.highlightedEntryKey,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: items.length,
      controller: scrollController,
      padding: const EdgeInsets.all(8.0),
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 8.0),
      itemBuilder: (context, index) {
        final item = items[index];
        bool isHighlighted = DioHelper.userId == item.id;
        return LeaderboardTile(
          key: isHighlighted ? highlightedEntryKey : null,
          rank: index + 1,
          entry: item,
          // isHighlighted: index == 0,
          isHighlighted: isHighlighted,
        );
      },
    );
  }
}
