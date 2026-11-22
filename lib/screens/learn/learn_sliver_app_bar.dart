import 'dart:math';

import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/logger.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
import 'package:educ_student/core/brand_colors.dart';
import 'package:educ_student/core/extensions.dart';
import 'package:educ_student/screens/learn/app_bar_action_buttons.dart';
import 'package:educ_student/screens/learn/attempts_timer.dart';
import 'package:educ_student/screens/learn/collection_list_modal.dart';
import 'package:educ_student/screens/learn/learn_cubit.dart';
import 'package:educ_student/screens/learn/root_collection_dropdown_button.dart';
import 'package:educ_student/widgets/custom_sliver_persistent_header_delegate.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LearnSliverAppBar extends StatefulWidget {
  const LearnSliverAppBar({
    super.key,
    required this.minExtent,
    required this.maxExtent,
  });

  final double minExtent;
  final double maxExtent;

  @override
  State<LearnSliverAppBar> createState() => _LearnSliverAppBarState();

  static void showCollectionListModal(BuildContext context) {
    final cubit = context.read<LearnCubit>();
    cubit.onRootCollectionsListAttached();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      clipBehavior: Clip.antiAlias,
      builder: (context) {
        return BlocProvider.value(
          value: cubit,
          child: BlocBuilder<LearnCubit, LearnState>(
            builder: (context, state) {
              final cubit = context.read<LearnCubit>();
              return CollectionListModal(
                isLoading: state is LearnCollectionsLoading,
                error: state is LearnCollectionsError
                    ? state.failure.failureCode.tr()
                    : null,
                rootCollections: cubit.rootCollections,
                subCollections: cubit.subCollections,
                onRootCollectionSelected: (collection) async {
                  final previousTopics = List.of(
                    cubit.topics,
                  ); // نسخة قبل التحديث
                  await cubit.updateSelectedRootCollection(
                    collection,
                  ); // استنى التحديث

                  Logger.Green("last Topics : ${previousTopics.length}");
                  Logger.Green("Topics : ${cubit.topics.length}");

                  final topicsChanged =
                      previousTopics.length != cubit.topics.length ||
                          !ListEquality().equals(
                            previousTopics.map((e) => e.id).toList(),
                            cubit.topics.map((e) => e.id).toList(),
                          );

                  if (topicsChanged) {
                    if(context.mounted)  Navigator.of(context).pop(); // اقفل المودال
                  }
                },
                onSubCollectionSelected: (collection) async {
                  final previousTopics = List.of(
                    cubit.topics,
                  ); // نسخة قبل التحديث
                  await cubit.updateSelectedSubCollection(
                    collection,
                  ); // استنى التحديث

                  Logger.Green("last Topics : ${previousTopics.length}");
                  Logger.Green("Topics : ${cubit.topics.length}");

                  final topicsChanged =
                      previousTopics.length != cubit.topics.length ||
                      !ListEquality().equals(
                        previousTopics.map((e) => e.id).toList(),
                        cubit.topics.map((e) => e.id).toList(),
                      );

                  if (topicsChanged) {
                    if(context.mounted)   Navigator.of(context).pop(); // اقفل المودال
                  }

                },

                selectedRootCollection: cubit.selectedRootCollection,
                selectedSubCollection: cubit.selectedSubCollection,
              );
            },
          ),
        );
      },
    );
  }
}

class _LearnSliverAppBarState extends State<LearnSliverAppBar>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      floating: true,
      pinned: true,
      delegate: CustomSliverPersistentHeaderDelegate.snap(
        vsync: this,
        snapConfiguration: FloatingHeaderSnapConfiguration(
          curve: Curves.ease,
          duration: const Duration(milliseconds: 400),
        ),
        minExtent: widget.minExtent + context.mediaQuery.viewPadding.top,
        maxExtent: widget.maxExtent + context.mediaQuery.viewPadding.top,
        paddingCollapsed: EdgeInsets.only(
          top: context.mediaQuery.viewPadding.top,
        ),
        paddingExpanded: EdgeInsets.only(
          top: context.mediaQuery.viewPadding.top + 12.0,
        ),
        topPanel: (t, s, o) => _buildTopPanel(context, t),
        bottomPanel: (t, s, o) => _buildBottomPanel(context, t),
        decoration: (t, s, o) => ShapeDecoration(
          color: context.colors.appBarBackground,
          shape: SmoothRectangleBorder(
            side: BorderSide(
              width: 2,
              color: context.colors.appBarBorder,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16.0),
            ),
          ),
          shadows: [
            BoxShadow(
              color: context.colors.appBarShadow,
              offset: const Offset(0.0, 5.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPanel(BuildContext context, ExtrapolationFactor t) {
    return SizedBox(
      height: widget.minExtent,
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              alignment: AlignmentDirectional.centerStart,
              padding: const EdgeInsetsDirectional.only(start: 16.0),
              child: _buildCollectionDropdown(),
            ),
          ),
          const AttemptsTimer(),
          const AttemptsActionButton(),
          const StreakActionButton(),
          const NotificationsActionButton(),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context, ExtrapolationFactor t) {
    return IgnorePointer(
      ignoring: true,
      child: BlocBuilder<LearnCubit, LearnState>(
        builder: (context, state) {
          final cubit = context.read<LearnCubit>();
          return Padding(
            padding: const EdgeInsets.only(
              right: 16.0,
              left: 16.0,
              bottom: 12.0,
              top: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(cubit.activePath),
                    Text(
                      "completed_percentage".tr(
                        args: [
                          cubit.calculateCompletedPercentage().toStringAsFixed(
                            0,
                          ),
                        ],
                      ),
                      style: Omnes.w500.getStyle(
                        fontSize: 16.0,
                        color: context.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                _buildProgressBar(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCollectionDropdown() {
    return BlocBuilder<LearnCubit, LearnState>(
      builder: (context, state) {
        final cubit = context.read<LearnCubit>();
        return RootCollectionDropdownButton(
          label: cubit.activeRootCollectionName,
          onPressed: () => LearnSliverAppBar.showCollectionListModal(context),
        );
      },
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return BlocBuilder<LearnCubit, LearnState>(
      builder: (context, state) {
        final cubit = context.read<LearnCubit>();

        return LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              alignment: AlignmentDirectional.centerStart,
              children: [
                Container(
                  height: 12,
                  decoration: ShapeDecoration(
                    shape: SmoothRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    color: context.colorScheme.outlineVariant.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ),
                AnimatedContainer(
                  curve: Curves.fastOutSlowIn,
                  duration: const Duration(milliseconds: 800),
                  height: 12,
                  width: max(
                    12,
                    constraints.maxWidth *
                        (cubit.calculateCompletedPercentage() / 100),
                  ),
                  alignment: Alignment.topCenter,
                  decoration: ShapeDecoration(
                    shape: SmoothRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    color: context.colorScheme.primaryContainer,
                  ),
                  child: const Divider(
                    thickness: 2,
                    indent: 4,
                    endIndent: 4,
                    height: 6,
                    color: BrandColors.primary3,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
