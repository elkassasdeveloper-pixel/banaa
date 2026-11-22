import 'dart:math';

import 'package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/services/cache_helper.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
import 'package:educ_student/assistant_cubit.dart';
import 'package:educ_student/core/assets.dart';
import 'package:educ_student/core/assistant_fab_location.dart';
import 'package:educ_student/core/constants.dart';
import 'package:educ_student/core/extensions.dart';
import 'package:educ_student/core/routes.dart';
import 'package:educ_student/screens/community/community_groups_cubit.dart';
import 'package:educ_student/screens/leaderboard/friends_leaderboard_cubit.dart';
import 'package:educ_student/screens/leaderboard/global_leaderboard_cubit.dart';
import 'package:educ_student/screens/other/settings_cubit.dart';
import 'package:educ_student/screens/post/popular_posts_cubit.dart';
import 'package:educ_student/screens/profile/profile_cubit.dart';
import 'package:material_ui/material_ui.dart' hide NavigationDestination, NavigationRailDestination;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

List<NavigationDestination> _destinations(BuildContext context) {
  final selectedIconColor = context.theme.navigationRailTheme.selectedIconTheme?.color;
  final unselectedIconColor = context.theme.navigationRailTheme.unselectedIconTheme?.color;

  return [
    NavigationDestination(
      icon: SvgPicture.asset(Svgs.learnOutlined, colorFilter: unselectedIconColor?.toColorFilter()),
      selectedIcon: SvgPicture.asset(
        Svgs.learnFilled,
        colorFilter: selectedIconColor?.toColorFilter(),
      ),
      label: "learn".tr(),
      tooltip: "learn".tr(),
    ),
    NavigationDestination(
      icon: SvgPicture.asset(
        Svgs.leaderboardOutlined,
        colorFilter: unselectedIconColor?.toColorFilter(),
      ),
      selectedIcon: SvgPicture.asset(
        Svgs.leaderboardFilled,
        colorFilter: selectedIconColor?.toColorFilter(),
      ),
      label: "leaderboard".tr(),
      tooltip: "leaderboard".tr(),
    ),
    NavigationDestination(
      icon: SvgPicture.asset(
        Svgs.communityOutlined,
        colorFilter: unselectedIconColor?.toColorFilter(),
      ),
      selectedIcon: SvgPicture.asset(
        Svgs.communityFilled,
        colorFilter: selectedIconColor?.toColorFilter(),
      ),
      label: "community".tr(),
      tooltip: "community".tr(),
    ),
    // NavigationDestination(
    //   icon: SvgPicture.asset(
    //     Svgs.exploreOutlined,
    //     colorFilter: unselectedIconColor?.toColorFilter(),
    //   ),
    //   selectedIcon: SvgPicture.asset(
    //     Svgs.exploreFilled,
    //     colorFilter: selectedIconColor?.toColorFilter(),
    //   ),
    //   label: "explore".tr(),
    //   tooltip: "explore".tr(),
    // ),
    NavigationDestination(
      icon: SvgPicture.asset(
        Svgs.profileOutlined,
        colorFilter: unselectedIconColor?.toColorFilter(),
      ),
      selectedIcon: SvgPicture.asset(
        Svgs.profileFilled,
        colorFilter: selectedIconColor?.toColorFilter(),
      ),
      label: "profile".tr(),
      tooltip: "profile".tr(),
    ),
  ];
}

bool dialogIsOpen = false;

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({super.key, required this.navigationShell});

  void onPageChanged(int index) {
    navigationShell.goBranch(
      index,
      // A common pattern when using bottom navigation bars is to support
      // navigating to the initial location when tapping the item that is
      // already active. This example demonstrates how to support this behavior,
      // using the initialLocation parameter of goBranch.
      initialLocation: true, // index == navigationShell.currentIndex,
    );
  }

  static const collapsedNavigationRailWidth = 80.0;
  static const extendedNavigationRailWidth = 240.0;

  @override
  Widget build(BuildContext context) {
    return BackButtonListener(
      // onBackButtonPressed: () async {
      //   if (_shouldPop(context)) {
      //     navigationShell.goBranch(0);
      //     return true;
      //   } else {
      //
      //     return await _showDialog(context);
      //   }
      // },
      onBackButtonPressed: () async {
        final location = GoRouterState.of(context).fullPath ?? "";

        if (_shouldPop(context)) {
          navigationShell.goBranch(0);
          return true;
        } else if (location == "/${Routes.LEARN}" && !dialogIsOpen) {
          dialogIsOpen = true;
          return await _showDialog(context);
        } else {
          dialogIsOpen = false;
          return false;
        }
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                AssistantCubit(appEventCode: CacheHelper.getLastOpenDaysDiff() < 3 ? 10 : 12),
          ),
          BlocProvider(create: (_) => GlobalLeaderboardCubit()),
          BlocProvider(create: (_) => FriendsLeaderboardCubit()),
          BlocProvider(create: (_) => CommunityGroupsCubit()),
          BlocProvider(create: (_) => PopularPostsCubit()),
          BlocProvider(create: (_) => ProfileCubit()),
        ],
        child: AdaptiveScaffold(
          useDrawer: false,
          navigationRailWidth: collapsedNavigationRailWidth,
          extendedNavigationRailWidth: extendedNavigationRailWidth,
          selectedIndex: navigationShell.currentIndex,
          onSelectedIndexChange: onPageChanged,
          navigationRailDestinationBuilder: (index, destination) {
            return NavigationRailDestination(
              icon: destination.icon,
              label: Text(destination.label),
              selectedIcon: destination.selectedIcon,
              indicatorShape: const SmoothRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              padding: EdgeInsets.zero,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          destinations: _destinations(context),
          leadingExtendedNavRail: _buildExtendedLeading(context),
          leadingUnextendedNavRail: _buildCollapsedLeading(context),
          // largeBreakpoint:
          //     const WidthPlatformBreakpoint(begin: 0, end: 0), // TODO:
          smallBreakpoint: shouldShowBottomNavBar(context)
              ? Breakpoints.small
              : const Breakpoint(beginWidth: 0, endWidth: 0),
          /*WidthPlatformBreakpoint(begin: 0, end: 0),*/
          body: (context) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: navigationShell,
              resizeToAvoidBottomInset: true,
              floatingActionButton: shouldShowBottomNavBar(context)
                  ? buildAssistantWidget(context)
                  : null,
              floatingActionButtonLocation: AssistantFabLocation(),
              floatingActionButtonAnimator: const NoAnimationFabMotionAnimator(),
            );
          },
        ),
      ),
    );
  }

  bool shouldShowBottomNavBar(BuildContext context) {
    final shouldShowConditions = [
      (location) => location == "/${Routes.LEARN}",
      (location) => location == "/${Routes.LEADERBOARD}",
      (location) => location == "/${Routes.COMMUNITY}",
      (location) => location == "/${Routes.PROFILE}",
    ];

    // final routeName = navigationShell.shellRouteContext.routerState.path ?? "";

    // final router = GoRouter.of(context);
    // final RouteMatch lastMatch =
    //     router.routerDelegate.currentConfiguration.last;
    // final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
    //     ? lastMatch.matches
    //     : router.routerDelegate.currentConfiguration;
    final String location = GoRouterState.of(context).fullPath ?? "";

    if (shouldShowConditions.any((condition) => condition(location))) {
      return true;
    } else {
      return false;
    }
  }

  bool _shouldPop(BuildContext context) {
    final shouldPopRoutePaths = [
      "/${Routes.LEADERBOARD}",
      "/${Routes.COMMUNITY}",
      "/${Routes.PROFILE}",
    ];

    final currentRoutePath = GoRouterState.of(context).fullPath ?? "";

    if (shouldPopRoutePaths.any((path) => currentRoutePath == path)) {
      return true;
    }

    return false;
  }

  Widget _buildCollapsedLeading(BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.topCenter,
      height: 80,
      child: Hero(tag: Strings.logoHeroTag, child: SvgPicture.asset(Svgs.banaaLogo, width: 48)),
    );
  }

  Widget _buildExtendedLeading(BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.topStart,
      height: 80,
      child: Hero(
        tag: Strings.logoHeroTag,
        child: SvgPicture.asset(Svgs.banaaLogoWithText, height: 48),
      ),
    );
  }

  Future<bool> _showDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: context.colorScheme.surfaceContainerLow,
          shape: SmoothRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          content: Text(
            "are_you_sure_you_want_to_exit".tr(),
            style: Omnes.w700.getStyle(fontSize: 20, color: context.colorScheme.primary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: TextButton.styleFrom(foregroundColor: context.colorScheme.primary),
              child: Text("no".tr(), style: Omnes.w500.getStyle(fontSize: 16)),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, false); // اختار نعم
              },
              style: FilledButton.styleFrom(
                foregroundColor: context.colorScheme.onError,
                backgroundColor: context.colorScheme.error,
              ),
              child: Text("yes".tr(), style: Omnes.w500.getStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );

    return result ?? true;
  }
}

String topicName = '';

Widget buildAssistantWidget(BuildContext context) {
  final backgroundColor = context.colorScheme.tertiaryContainer;
  final outlineColor = context.colorScheme.tertiaryContainer;
  final adaptedOutlineColor = context.isDark ? outlineColor.lighten(20) : outlineColor.darken(20);
  final textColor = context.colorScheme.onTertiaryContainer;

  return BlocBuilder<AssistantCubit, AssistantState>(
    builder: (context, state) {
      final cubit = context.read<AssistantCubit>();
      final showBubble = cubit.isAssistantActive && cubit.isBubbleShown;
      if (cubit.assistantBubbles.isEmpty) {
        return const SizedBox.shrink();
      }
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: context.mediaQuery.size.height * 0.4,
          maxWidth: min(
            600,
            !context.isLarge
                ? double.infinity
                : context.mediaQuery.size.width * 0.6 - 240.0 - 16.0 + Consts.assistantSize,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          alignment: AlignmentDirectional.bottomStart,
          children: [
            AnimatedPositionedDirectional(
              duration: assistantShowDuration,
              curve: Curves.easeOutCubic,
              start: 16.0,
              bottom: cubit.isAssistantActive ? 0 : -Consts.assistantSize - 16.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🖼️ صورة المساعد
                  if (cubit.getCurrentBubble()?.imageUrl.isNotEmpty ?? false)
                    CachedNetworkImage(
                      imageUrl:Uri.encodeFull(cubit.getCurrentBubble()!.imageUrl),
                      memCacheWidth: 300,
                      imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
                      width: Consts.assistantSize,
                      height: Consts.assistantSize,
                      fit: BoxFit.cover,
                    )
                  else
                    // الصورة الافتراضية (لو مفيش صورة)
                    CachedNetworkImage(
                      imageUrl:Uri.encodeFull(context.read<SettingsCubit>().prefs.fileName),
                      memCacheWidth: 300,
                      imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
                      width: Consts.assistantSize,
                      height: Consts.assistantSize,
                      fit: BoxFit.cover,
                    ),
                ],
              ),
            ),
            // 💬 فقّاعة النص
            () {
              final text = cubit.getCurrentBubble()?.bubbleTextA ?? "";
              var updatedText = text;
              final replacements = {
                'user_name': context.user?.firstName ?? '',
                'topic_name': topicName,
              };
              replacements.forEach((key, value) {
                updatedText = updatedText.replaceAll(key, value);
              });
              return PositionedDirectional(
                start: Consts.assistantSize + 8,
                bottom: Consts.assistantSize,
                end: 16.0,
                child: Align(
                  alignment: AlignmentDirectional.bottomStart,
                  child: IgnorePointer(
                    ignoring: !showBubble,
                    child: AnimatedOpacity(
                      duration: bubbleTransitionDuration,
                      opacity: showBubble ? 1.0 : 0.0,
                      child: TweenAnimationBuilder(
                        curve: Curves.easeInOutCubic,
                        duration: bubbleTransitionDuration,
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              color: backgroundColor,
                              border: Border.all(
                                width: 2.0,
                                color: adaptedOutlineColor,
                                strokeAlign: value * 6.0,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                updatedText,
                                style: Omnes.w400.getStyle(fontSize: 16.0, color: textColor),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            }(),
          ],
        ),
      );
    },
  );
}

class AssistantController {
  final AssistantCubit cubit;

  AssistantController(this.cubit);

  void setEvent(int code) => cubit.setEventCode(code);

  void start() => cubit.triggerAssistant();

  void stop() => cubit.deactivateAssistant();

  void reset() => cubit.resetAssistant();

  void showAssistantOverlay(BuildContext context) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: 80,
        left: 16,
        right: 16,
        child: Material(color: Colors.transparent, child: buildAssistantWidget(context)),
      ),
    );

    overlay.insert(entry);

    // Hide it after a few seconds
    Future.delayed(const Duration(seconds: 5), () {
      entry.remove();
    });
  }
}

extension AssistantControllerX on BuildContext {
  AssistantController get assistant => AssistantController(read<AssistantCubit>());
}
