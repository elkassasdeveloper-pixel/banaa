// import 'dart:math';
//
// import 'package:educ_core/educ_core.dart';
// import 'package:educ_core/utils/extensions.dart';
// import 'package:educ_core/utils/helpers.dart';
// import 'package:educ_core/utils/text_styles.dart';
// import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
// import 'package:educ_student/core/brand_colors.dart';
// import 'package:educ_student/core/extensions.dart';
// import 'package:educ_student/screens/learn//learn_cubit.dart';
// import 'package:educ_student/screens/profile/profile_cubit.dart';
// import 'package:educ_student/screens/learn/learn_screen_desktop.dart';
// import 'package:educ_student/screens/learn/learn_sliver_app_bar.dart';
// import 'package:educ_student/screens/learn/topics_list.dart';
// import 'package:educ_student/screens/main_screen.dart';
// import 'package:material_ui/material_ui.dart';
// import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// class LearnDesktopBody extends SlotLayout {
//   const LearnDesktopBody({super.key}) : super(config: const {});
//
//   @override
//   Map<Breakpoint, SlotLayoutConfig?> get config {
//     return {
//       Breakpoints.standard: SlotLayout.from(
//         key: const Key('LEARN_DESKTOP_BODY'),
//         inAnimation: AdaptiveScaffold.fadeIn,
//         outAnimation: AdaptiveScaffold.fadeOut,
//         builder: (context) {
//           const padding = EdgeInsetsDirectional.only(
//             start: 48.0,
//             end: 24.0,
//             top: 24.0,
//           );
//           final screenWidth = context.mediaQuery.size.width;
//           final areaWidth =
//               screenWidth - MainScreen.extendedNavigationRailWidth - (8 * 2);
//           // final bodyWidth = areaWidth * LearnScreenDesktop.bodyRatio;
//           final sBodyWidth = areaWidth * (1 - LearnScreenDesktop.bodyRatio);
//
//           return BlocBuilder<LearnCubit, LearnState>(
//             builder: (context, state) {
//               final cubit = context.read<LearnCubit>();
//               return Padding(
//                 padding: padding,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildWelcomeText(context),
//                     const SizedBox(height: 12.0),
//                     _buildSloganText(context),
//                     const SizedBox(height: 16.0),
//                     const Divider(),
//                     const SizedBox(height: 24.0),
//                     _buildCollectionCard(context),
//                     Expanded(
//                       child: CustomScrollView(
//                         key: cubit.listKey,
//                         controller: cubit.scrollController,
//                         slivers: [
//                           TopicsList.buildTopicsList(
//                             translation: Offset(
//                               -areaWidth + (sBodyWidth / 2),
//                               0,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     };
//   }
//
//   Widget _buildWelcomeText(BuildContext context) {
//     return BlocBuilder<ProfileCubit, ProfileState>(
//       builder: (context, state) {
//         final profile = context.read<ProfileCubit>().profile;
//         return Text.rich(
//           TextSpan(
//             children: [
//               TextSpan(
//                 text: "welcome_back".tr(),
//                 style: Omnes.w500.getStyle(
//                   fontSize: 24.0,
//                   color: context.colors.subHeadline,
//                 ),
//               ),
//               TextSpan(
//                 text: "${profile?.firstName ?? ""}!",
//                 style: Omnes.w700.getStyle(
//                   fontSize: 24.0,
//                   color: context.colors.headline,
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildSloganText(BuildContext context) {
//     return Text(
//       "learn_screen_slogan".tr(),
//       style: Omnes.w500.getStyle(
//         fontSize: 16.0,
//         color: context.colors.bodyText,
//       ),
//     );
//   }
//
//   Widget _buildCollectionCard(BuildContext context) {
//     final cubit = context.read<LearnCubit>();
//     return InkWell(
//       customBorder: SmoothRectangleBorder(
//         borderRadius: BorderRadius.circular(16.0),
//       ),
//       onTap: () => LearnSliverAppBar.showCollectionListModal(context),
//       child: Container(
//         padding: const EdgeInsets.all(24.0),
//         decoration: ShapeDecoration(
//           gradient: context.colors.linearLearnCardBackgroundGradient,
//           shape: SmoothRectangleBorder(
//             borderRadius: BorderRadius.circular(16.0),
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             OverflowBar(
//               spacing: 16.0,
//               alignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   cubit.activeRootCollectionName ?? "",
//                   style: Omnes.w700.getStyle(
//                     fontSize: 24.0,
//                     color: context.colorScheme.primary,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(width: 16.0),
//                 Text(
//                   "remaining".tr(
//                     args: [
//                       formatMinutes(cubit.calculateRemainingReadingTime()),
//                     ],
//                   ),
//                   style: Omnes.w500.getStyle(
//                     fontSize: 16.0,
//                     color: context.colorScheme.primary,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16.0),
//             Text(
//               "completed_percentage".tr(
//                 args: [cubit.calculateCompletedPercentage().toStringAsFixed(0)],
//               ),
//               style: Omnes.w500.getStyle(
//                 fontSize: 16.0,
//                 color: context.colorScheme.primary,
//               ),
//             ),
//             const SizedBox(height: 8.0),
//             _buildProgressBar(context, cubit),
//           ],
//         ),
//       ),
//     );
//   }
//
//   _buildProgressBar(BuildContext context, LearnCubit cubit) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return Stack(
//           alignment: AlignmentDirectional.centerStart,
//           children: [
//             Container(
//               height: 16,
//               decoration: ShapeDecoration(
//                 shape: SmoothRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 color: context.colorScheme.surface.withValues(alpha: 0.3),
//               ),
//             ),
//             AnimatedContainer(
//               curve: Curves.fastOutSlowIn,
//               duration: const Duration(milliseconds: 800),
//               height: 16,
//               width: max(
//                   12,
//                   constraints.maxWidth *
//                       (cubit.calculateCompletedPercentage() / 100)),
//               alignment: Alignment.topCenter,
//               decoration: ShapeDecoration(
//                 shape: SmoothRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 color: context.colorScheme.primaryContainer,
//               ),
//               child: const Divider(
//                 thickness: 2,
//                 indent: 4,
//                 endIndent: 4,
//                 height: 6,
//                 color: BrandColors.primary3,
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
