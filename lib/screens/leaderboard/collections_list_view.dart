import 'package:educ_core/data/models/collection.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/widgets/error_message_card.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
import 'package:educ_student/core/assets.dart';
import 'package:educ_student/screens/leaderboard/friends_leaderboard_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _listPaddingVertical = 8.0;
const _listPaddingHorizontal = 16.0;
const _itemWidth = 80.0;
const _itemHeight = 100.0;

class CollectionsListView extends StatelessWidget {
  const CollectionsListView({super.key});

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: _itemHeight + _listPaddingVertical * 2,
      child: BlocBuilder<FriendsLeaderboardCubit, FriendsLeaderboardState>(
        builder: (context, state) {
          final cubit = context.read<FriendsLeaderboardCubit>();
          final visibleRootCollections = cubit.rootCollections
              .where((c) => c.himaIsVisable == "Y"&& c.himaIsActive == "Y").toList();

          if (state is FriendsLeaderboardCollectionsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is FriendsLeaderboardCollectionsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ErrorMessageCard.failure(failure: state.failure),
              ),
            );
          }

          return Material(
            type: MaterialType.transparency,
            child: Center(
              child: ListView.builder(
                shrinkWrap: true,
                controller: cubit.collectionsScrollController,
                scrollDirection: Axis.horizontal,
                itemCount: visibleRootCollections.length,
                padding: const EdgeInsets.symmetric(
                  vertical: _listPaddingVertical,
                  horizontal: _listPaddingHorizontal,
                ),
                itemBuilder: (context, index) {
                  final item = visibleRootCollections[index];
                  return _buildCollectionItem(context, cubit, item, index);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCollectionItem(BuildContext context,
      FriendsLeaderboardCubit cubit, Collection item, int index) {
    bool isSelected = cubit.selectedCollectionIndex == index;
    return SizedBox(
      key: isSelected ? cubit.selectedCollectionKey : null,
      width: _itemWidth,
      height: _itemHeight,
      child: InkWell(
        customBorder: SmoothRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        onTap: () => cubit.onRootCollectionSelected(index),
        child: Opacity(
          opacity: isSelected ? 1.0 : 0.3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Stack(
              fit: StackFit.loose,
              children: [
                Positioned.fill(
                  child: SvgPicture.asset(
                    Svgs.shield,
                    colorFilter: Colors.accents
                        .whereIndexed((i, _) => i.isEven)
                        .toList()[index % Colors.primaries.length]
                        .toColorFilter(BlendMode.modulate),
                  ),
                ),
                Center(
                  child: SvgPicture.asset(
                    Svgs.quranCollection,
                    colorFilter: Colors.accents
                        .whereIndexed((i, _) => i.isEven)
                        .toList()[index % Colors.primaries.length]
                        .toColorFilter(BlendMode.modulate),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
