import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/logger.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/widgets/error_message_card.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
import 'package:educ_student/core/extensions.dart';
import 'package:educ_student/screens/community/community_groups_cubit.dart';
import 'package:educ_student/screens/community/group_item.dart';
import 'package:educ_student/screens/post/popular_posts_cubit.dart';
import 'package:educ_student/widgets/custom_sliver_persistent_header_delegate.dart';
import 'package:educ_student/widgets/search_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommunitySliverAppBar extends StatefulWidget {
  const CommunitySliverAppBar({
    super.key,
    required this.minExtent,
    required this.maxExtent,
  });

  final double minExtent;
  final double maxExtent;

  @override
  State<CommunitySliverAppBar> createState() => _CommunitySliverAppBarState();
}

class _CommunitySliverAppBarState extends State<CommunitySliverAppBar>
    with TickerProviderStateMixin {

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applySearch(BuildContext context) {
    final query = _searchController.text;
    context.read<CommunityGroupsCubit>().search(query);
    context.read<PopularPostsCubit>().search(query);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      floating: true,
      pinned: true,
      delegate: CustomSliverPersistentHeaderDelegate.snap(
        vsync: this,
        snapConfiguration: FloatingHeaderSnapConfiguration(
          curve: Curves.ease,
          duration: const Duration(milliseconds: 200),
        ),
        minExtent: widget.minExtent + context.mediaQuery.viewPadding.top,
        maxExtent: widget.maxExtent + context.mediaQuery.viewPadding.top,
        paddingCollapsed:
            EdgeInsets.only(top: context.mediaQuery.viewPadding.top + 16.0),
        paddingExpanded:
            EdgeInsets.only(top: context.mediaQuery.viewPadding.top + 24.0),
        topPanel: (t, s, o) => _buildTopPanel(context, t),
        bottomPanel: (t, s, o) => _buildBottomPanel(context, t),
        decoration: (t, s, o) {
          bool isScrolled = s > widget.minExtent;
          return ShapeDecoration(
            color: Color.lerp(context.colors.background,
                context.colors.appBarBackground, t(1.0) * 1.0),
            shape: SmoothRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(t(0.5) * 12.0),
              ),
            ),
            shadows: [
              BoxShadow(
                color: context.colorScheme.shadow,
                blurRadius: isScrolled || o ? 8 : 0.0,
                offset: Offset(0, isScrolled || o ? 2 : 0.0),
              ),
            ],
          );
        },
        bottomPanelOpacityFactor: 0.1,
      ),
    );
  }

  Widget _buildTopPanel(BuildContext context, ExtrapolationFactor t) {
    return SizedBox(
      height: widget.minExtent,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "community".tr(),
              style: Omnes.w700
                  .getStyle(fontSize: 24, color: context.colorScheme.primary),
            ),
          ),
          const SizedBox(height: 12.0),
          SearchBarWithFilter(
            controller: _searchController,
            onFilterPressed: () => _applySearch(context),
            onSubmitted: (_) => _applySearch(context),
            onChanged: (v) {
              if (v.isEmpty) _applySearch(context); // reset when cleared
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context, ExtrapolationFactor t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 5),
          child: Text(
            "groups".tr(),
            style: Omnes.w500
                .getStyle(fontSize: 20, color: context.colors.subHeadline),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: BlocBuilder<CommunityGroupsCubit, CommunityGroupsState>(
            builder: (context, state) {
              final cubit = context.read<CommunityGroupsCubit>();
              final groups = cubit.filteredGroups;

              if (state is CommunityGroupsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is CommunityGroupsError) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ErrorMessageCard.failure(
                    failure: state.failure,
                    onRetry: cubit.fetch,
                  ),
                );
              } else if (groups.isEmpty) {
                return Center(child: Text("errors.empty_data".tr()));
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: groups.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  Logger.Green("group: ${group.id}");
                  return GroupItem(group: group);
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(width: 12.0);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // void _showSearchFilterModal(BuildContext context) {
  //   showModalBottomSheet(
  //     useRootNavigator: true,
  //     context: context,
  //     shape: const SmoothRectangleBorder(
  //       borderRadius: BorderRadius.only(
  //         topLeft: Radius.circular(16.0),
  //         topRight: Radius.circular(16.0),
  //       ),
  //     ),
  //     clipBehavior: Clip.antiAlias,
  //     builder: (context) {
  //       return SingleChildScrollView(
  //         padding: const EdgeInsets.all(16.0),
  //         child: Column(
  //           children: [
  //             Row(
  //               children: [
  //                 Text(
  //                   "search_filters".tr(),
  //                   style: Omnes.w700.getStyle(
  //                       fontSize: 16, color: context.colorScheme.primary),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 16.0),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
}
