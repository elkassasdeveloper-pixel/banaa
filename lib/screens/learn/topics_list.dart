import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_student/core/assets.dart';
import 'package:educ_student/core/brand_colors.dart';
import 'package:educ_student/core/extensions.dart';
import 'package:educ_student/screens/learn//learn_sliver_app_bar.dart';
import 'package:educ_student/screens/learn/learn_cubit.dart';
import 'package:educ_student/screens/learn/topic_list_item.dart';
import 'package:educ_student/widgets/path_line_painter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TopicsList extends StatelessWidget {
  const TopicsList({
    super.key,
    required this.onRefresh,
  });

  final RefreshCallback onRefresh;

  static const double minAppBarHeight = kToolbarHeight;
  static const double maxAppBarHeight = 124;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LearnCubit>();

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: BlocBuilder<LearnCubit, LearnState>(
        builder: (context, state) {
          return Align(
            alignment: Alignment.topCenter,
            child: Stack(
              children: [
                _buildBackgroundDecoration(context),
                CustomScrollView(
                  controller: cubit.scrollController,
                  slivers: [
                    const LearnSliverAppBar(
                      minExtent: minAppBarHeight,
                      maxExtent: maxAppBarHeight,
                    ),
                    buildTopicsList(
                        translation: const Offset(0, maxAppBarHeight)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget buildTopicsList({Offset translation = const Offset(0, 0)}) {
    return BlocBuilder<LearnCubit, LearnState>(
      builder: (context, state) {
        final cubit = context.read<LearnCubit>();
        final topics = cubit.topics;
        if (state is LearnTopicsLoading) {
          return const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (topics.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Text("errors.empty_data".tr()),
            ),
          );
        }

        return SliverList(
          delegate: _CustomListDelegate(
            items: topics.mapIndexed((index, topic) {
              return TopicListItem(
                topic: topic,
                horizontalPosition:
                    calculateZigzagPosition(index, topics.length),
                isCentered: index == 0 || index == topics.length - 1,
              );
            }).toList(),
            itemBuilder: (context, index, previousItem, item) {
              return CustomPaint(
                willChange: true,
                isComplex: true,
                painter: PathLinePainter(
                  color: previousItem?.topic.isFinished == true
                      ? BrandColors.secondary1
                      : BrandColors.primary1.withValues(alpha: 0.2),
                  itemKey: item.painterKey,
                  endItemKey: previousItem?.painterKey,
                  previousIndex: index - 1,
                  scrollController: cubit.scrollController,
                  globalStartOffset: cubit.listKey
                          .getBounds(translation.translate(
                              0, context.mediaQuery.viewPadding.top))
                          ?.topLeft ??
                      Offset.zero,
                ),
                child: item,
              );
            },
          ),
        );
      },
    );
  }

  static int calculateZigzagPosition(int index, int topicsLength) {
    const maxPositions = TopicListItem.maxPositions;
    const centerPosition = maxPositions ~/ 2;
    index -= centerPosition;
    // int direction = (index ~/ (2 * maxPositions)) % 2;
    int positionInDirection = index % (2 * maxPositions - 2);

    int adjustedPosition = positionInDirection >= maxPositions
        ? 2 * maxPositions - 2 - positionInDirection
        : positionInDirection;

    return adjustedPosition;
  }

  Widget _buildBackgroundDecoration(BuildContext context) {
    const double height = 400;
    const double heightFactor = 0.6;

    return Positioned.fill(
      child: OverflowBox(
        maxHeight: double.infinity,
        alignment: Alignment.topCenter,
        child: Column(
          children: List.generate(
            (context.mediaQuery.size.height / (height * heightFactor)).ceil(),
            (index) => Align(
              heightFactor: heightFactor,
              alignment:
                  index % 2 == 0 ? Alignment.centerLeft : Alignment.centerRight,
              child: SizedBox(
                width: 70,
                height: height,
                child: SvgPicture.asset(
                  Svgs.circlePattern,
                  fit: BoxFit.fitHeight,
                  height: height,
                  alignment: index % 2 == 0
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  colorFilter: context.colorScheme.outline
                      .withValues(alpha: 0.2)
                      .toColorFilter(BlendMode.modulate),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

typedef ItemBuilder = Widget Function(
  BuildContext context,
  int index,
  TopicListItem? previousItem,
  TopicListItem item,
);

class _CustomListDelegate extends SliverChildBuilderDelegate {
  final List<TopicListItem> items;

  _CustomListDelegate({
    required this.items,
    required ItemBuilder itemBuilder,
  }) : super(
          (context, index) {
            return itemBuilder(
              context,
              index,
              index > 0 ? items[index - 1] : null,
              items[index],
            );
          },
          childCount: items.length,
        );

  @override
  bool shouldRebuild(covariant _CustomListDelegate oldDelegate) {
    return !identical(oldDelegate.items, items);
  }
}
