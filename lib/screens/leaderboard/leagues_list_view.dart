import 'package:educ_core/data/models/league.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/widgets/error_message_card.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
import 'package:educ_student/screens/leaderboard/global_leaderboard_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _listPaddingVertical = 8.0;
const _listPaddingHorizontal = 16.0;
const _itemWidth = 80.0;
const _itemHeight = 100.0;

class LeaguesListview extends StatelessWidget {
  const LeaguesListview({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _itemHeight + _listPaddingVertical * 2,
      child: BlocBuilder<GlobalLeaderboardCubit, GlobalLeaderboardState>(
        builder: (context, state) {
          final cubit = context.read<GlobalLeaderboardCubit>();

          if (state is GlobalLeaderboardLeaguesLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is GlobalLeaderboardLeaguesError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ErrorMessageCard.failure(failure: state.failure),
              ),
            );
          }

          return Material(
            // color: context.colors.background,
            type: MaterialType.transparency,
            child: Center(
              child: ListView.builder(
                shrinkWrap: true,
                prototypeItem: _prototypeItem(),
                controller: cubit.leaguesScrollController,
                scrollDirection: Axis.horizontal,
                itemCount: cubit.leagues.length,
                padding: const EdgeInsets.symmetric(
                  vertical: _listPaddingVertical,
                  horizontal: _listPaddingHorizontal,
                ),
                itemBuilder: (context, index) {
                  final item = cubit.leagues[index];
                  return _buildLeagueItem(context, cubit, item, index);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeagueItem(BuildContext context, GlobalLeaderboardCubit cubit,
      League item, int index) {
    bool isSelected = cubit.selectedLeagueIndex == index;
    bool isLocked = !item.isLocked;
    return SizedBox(
      key: isSelected ? cubit.selectedLeagueKey : null,
      // width: isLocked ? _itemWidth / 1.4 : _itemWidth,
      // height: isLocked ? _itemHeight / 1.4 : _itemHeight,
      width: _itemWidth,
      height: _itemHeight,
      child: InkWell(
        onTap: isLocked
            ? () => _showLockedMessage(context)
            : () => cubit.onLeagueSelected(index),
        customBorder: SmoothRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: _buildImage(context, isLocked, isSelected, item),
        ),
      ),
    );
  }

  Widget _buildImage(
      BuildContext context, bool isLocked, bool isSelected, League item) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: !isSelected ? 0.2 : 1.0,
          child: CachedNetworkImage(
            imageUrl:Uri.encodeFull(item.fileName),
            memCacheWidth: 300,
            imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
            fit: BoxFit.contain,
          ),
        ),
        if (isLocked)
          PositionedDirectional(
            bottom: 0,
            start: 0,
            child: Opacity(
              opacity: 0.7,
              child: Icon(
                size: 18,
                Icons.lock_rounded,
                color: context.colorScheme.onSurface,
                shadows: [
                  Shadow(
                    color: context.colorScheme.onSurfaceVariant,
                    offset: const Offset(0, 0),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          )
      ],
    );

    // return SvgPicture.asset(
    //   Svgs.shield,
    //   colorFilter: isLocked
    //       ? context.colorScheme.onSurface.withValues(alpha: 0.5).toColorFilter()
    //       : Colors.accents
    //           .whereIndexed((i, _) => i.isEven)
    //           .toList()[index % Colors.primaries.length]
    //           .lighten(80)
    //           .toColorFilter(BlendMode.modulate),
    // );
  }

  void _showLockedMessage(BuildContext context) {
    context.showNormalSnackBar(
      'rank_is_locked'.tr(),
      icon: const Icon(Icons.lock_rounded),
    );
  }

  Widget _prototypeItem() {
    return const SizedBox(
      width: _itemWidth,
      height: _itemHeight,
    );
  }
}
