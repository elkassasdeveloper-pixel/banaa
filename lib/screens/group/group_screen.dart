import 'package:educ_core/data/models/group.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/helpers.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
import 'package:educ_student/core/assets.dart';
import 'package:educ_student/core/brand_colors.dart';
import 'package:educ_student/core/routes.dart';
import 'package:educ_student/screens/community/community_groups_cubit.dart';
import 'package:educ_student/screens/group/group_about_tab.dart';
import 'package:educ_student/screens/group/group_cubit.dart';
import 'package:educ_student/screens/group/group_members_cubit.dart';
import 'package:educ_student/screens/group/group_members_tab.dart';
import 'package:educ_student/screens/group/group_posts_cubit.dart';
import 'package:educ_student/screens/group/group_posts_tab.dart';
import 'package:educ_student/widgets/data_screen.dart';
import 'package:educ_student/widgets/gradiant_screen.dart';
import 'package:educ_student/widgets/search_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applySearch(BuildContext context) {
    final query = _searchController.text;
    context.read<GroupPostsCubit>().search(query);
    context.read<GroupMembersCubit>().search(query);
    FocusScope.of(context).unfocus();
  }
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GroupCubit>();
    final groupId = cubit.group?.id ?? "";
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => GroupPostsCubit(groupId)),
        BlocProvider(create: (context) => GroupMembersCubit(groupId)),
      ],
      child: BlocListener<GroupCubit, GroupState>(
        listener: (context, state) {
          if (state is GroupJoinError) {
            context.showFailureSnackBar(state.failure);
          }
          if (state is GroupLeaveError) {
            context.showFailureSnackBar(state.failure);
          }
          if (state is GroupJoinSuccess) {
            context.showSuccessSnackBar("group_joined_success".tr());
          }
          if (state is GroupLeaveSuccess) {
            context.showSuccessSnackBar("group_left_success".tr());
            context.pop();
          }
          if (state is GroupLoaded || state is GroupSubscriptionChanged) {
            final group = cubit.group;
            if (group != null) {
              context.read<CommunityGroupsCubit>().updateGroup(group);
            }
          }
        },
        child: DataScreen<GroupCubit, GroupState>(
          fetch: (cubit) => cubit.fetch(),
          isLoading: (state) => state is GroupLoading,
          isLoaded: (state) => state is GroupLoaded,
          failure: (state) => state is GroupError ? state.failure : null,
          isEmpty: (cubit, state) => cubit.group == null,
          builder: (context, cubit, state) {
            final group = cubit.group!;
            return DefaultTabController(
              length: 3,
              child: GradiantScreen(
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: AppBar(
                    automaticallyImplyLeading: false,
                    centerTitle: false,
                    title: _buildTitle(context, group,cubit.groupName),
                    toolbarHeight: 80,
                    actions: [
                      if (cubit.group?.hasJoined == 1)
                        _buildSubscribeOptionsDropdown(context, cubit, state)
                      else
                        _buildJoinButton(context, cubit, state),
                      const SizedBox(width: 16.0),
                    ],
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(110),
                      child: Column(
                        children: [
                          SearchBarWithFilter(
                            controller: _searchController,
                            onFilterPressed: () => _applySearch(context),
                            onSubmitted: (_) => _applySearch(context),
                            onChanged: (v) {
                              if (v.isEmpty) _applySearch(context); // reset when cleared
                            },
                          ),
                          TabBar(
                            indicatorSize: TabBarIndicatorSize.tab,
                            labelStyle: Omnes.w700.getStyle(fontSize: 16.0),
                            unselectedLabelColor: context.colorScheme.primary,
                            dividerColor: Colors.transparent,
                            tabs: [
                              Tab(text: "posts".tr()),
                              Tab(text: "members".tr()),
                              Tab(text: "about_group".tr()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  floatingActionButton: buildFloatingActionButton(context),
                  body: const TabBarView(
                    children: [GroupPostsTab(), GroupMembersTab(), GroupAboutTab()],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  FloatingActionButton? buildFloatingActionButton(BuildContext context) {
    final cubit = context.read<GroupCubit>();
    if (cubit.group?.hasJoined != 1) return null;

    return FloatingActionButton.extended(
      tooltip: "new_post".tr(),
      onPressed: () {
        // context.goNamed(Routes.CREATE_POST);
        GoRouter.of(context).pushNamed(
          Routes.CREATE_POST,

          ///
          pathParameters: {'postId': "1"},
        );
      },
      shape: SmoothRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      backgroundColor: context.colorScheme.primary,
      foregroundColor: context.colorScheme.onPrimary,
      label: Text("new_post".tr()),
      icon: const Icon(Icons.add_rounded),
    );
  }

  FilledButton _buildJoinButton(BuildContext context, GroupCubit cubit, GroupState state) {
    return FilledButton(
      onPressed: cubit.joinGroup,
      style: FilledButton.styleFrom(
        backgroundColor: BrandColors.primary1,
        foregroundColor: context.colorScheme.onPrimary,
        textStyle: Omnes.w700.getStyle(fontSize: 14.0),
      ),
      child: state is GroupJoinLoading || state is GroupSilentLoading
          ? SizedBox.square(
              dimension: 16.0,
              child: CircularProgressIndicator(color: context.colorScheme.onPrimary),
            )
          : Text("join".tr()),
    );
  }

  Widget _buildSubscribeOptionsDropdown(BuildContext context, GroupCubit cubit, GroupState state) {
    const padding = EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0);

    if (state is GroupLeaveLoading) {
      return IconButton(
        onPressed: () {},
        style: IconButton.styleFrom(
          backgroundColor: BrandColors.primary1.withValues(alpha: 0.08),
          foregroundColor: BrandColors.primary1,
        ),
        icon: SizedBox.square(
          dimension: 16.0,
          child: CircularProgressIndicator(color: context.colorScheme.primary),
        ),
      );
    }

    return PopupMenuButton<SubscriptionOption?>(
      tooltip: "subscription_options".tr(),
      initialValue: cubit.subscriptionOption,
      onSelected: cubit.setSubscription,
      color: context.colorScheme.surface,
      shape: SmoothRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      splashRadius: 8.0,
      constraints: const BoxConstraints(minWidth: 132.0),
      // surfaceTintColor: BrandColors.primary1,
      itemBuilder: (context) {
        return [
          ...SubscriptionOption.values.map((option) {
            final isSelected = option == cubit.subscriptionOption;
            return PopupMenuItem<SubscriptionOption>(
              value: option,
              height: 40.0,
              padding: EdgeInsets.zero,
              child: Container(
                padding: padding,
                color: isSelected
                    ? BrandColors.primary1.alphaBlend(context.colorScheme.surface, 0.1)
                    : null,
                child: Center(
                  child: _buildSubscriptionOptionItem(
                    context,
                    iconPath: option.iconPath,
                    text: option.getTranslationKey().tr(),
                    isSelected: isSelected,
                  ),
                ),
              ),
            );
          }),
          const PopupMenuDivider(height: 1),
          PopupMenuItem(
            onTap: cubit.leaveGroup,
            value: null,
            padding: padding,
            height: 40.0,
            child: _buildSubscriptionOptionItem(
              context,
              iconPath: Svgs.leaveGroup,
              text: "leave_group".tr(),
              isSelected: false,
              color: context.colorScheme.errorContainer,
            ),
          ),
        ];
      },
      child: Container(
        padding: padding,
        decoration: ShapeDecoration(
          color: BrandColors.primary1.withValues(alpha: 0.08),
          shape: SmoothRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              cubit.subscriptionOption.iconPath,
              colorFilter: BrandColors.primary1.toColorFilter(),
              height: 16.0,
              width: 16.0,
            ),
            const SizedBox(width: 8.0),
            Text(
              cubit.subscriptionOption.getShortTranslationKey().tr(),
              style: Omnes.w700.getStyle(fontSize: 14.0, color: BrandColors.primary1),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 4.0),
            SvgPicture.asset(
              Svgs.arrowDown,
              colorFilter: BrandColors.primary1.toColorFilter(),
              height: 16.0,
              width: 16.0,
            ),
          ],
        ),
      ),
    );
  }

  Row _buildSubscriptionOptionItem(
    BuildContext context, {
    required String iconPath,
    required String text,
    required bool isSelected,
    Color? color,
  }) {
    final color0 = color ?? (isSelected ? BrandColors.primary1 : context.colorScheme.primary);
    return Row(
      children: [
        SvgPicture.asset(iconPath, colorFilter: color0.toColorFilter(), height: 16.0, width: 16.0),
        const SizedBox(width: 8.0),
        Text(text, style: Omnes.w700.getStyle(color: color0)),
      ],
    );
  }

  Widget _buildTitle(BuildContext context, Group group,String name) {
    return InkWell(
      customBorder: const SmoothRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
      onTap: () => context.pop(),
      child: Container(
        padding: const EdgeInsetsDirectional.only(end: 8.0, top: 8.0, bottom: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              Svgs.backArrow,
              colorFilter: context.colorScheme.primary.toColorFilter(),
              matchTextDirection: true,
            ),
            const SizedBox(width: 8.0),
            Container(
              height: 40.0,
              width: 40.0,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: CachedNetworkImage(
                imageUrl:Uri.encodeFull(group.fileName),
                memCacheWidth: 300,
                imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
                errorWidget: (context, url, error) {
                  return Container(color: context.colorScheme.primaryContainer);
                },
              ),
            ),
            const SizedBox(width: 8.0),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Omnes.w500.getStyle(fontSize: 18, color: context.colorScheme.primary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _getMembersCountText(context, group),
                    style: Omnes.w400.getStyle(
                      fontSize: 14,
                      color: context.colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // void _showSearchFilterModal(BuildContext context) {}
  String _getMembersCountText(BuildContext context, Group group) {
    final formattedValue = formatIntegerRecord(group.membersCount);

    return "${formattedValue.number} ${formattedValue.unit} ${"joined_members".tr()}";
  }
}
