// import 'package:educ_student/screens/learn/app_bar_action_buttons.dart';
// import 'package:material_ui/material_ui.dart';
// import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
//
// class LearnDesktopTopNavigation extends SlotLayout {
//   const LearnDesktopTopNavigation({super.key}) : super(config: const {});
//
//   @override
//   Map<Breakpoint, SlotLayoutConfig?> get config {
//     return {
//       Breakpoints.standard: SlotLayout.from(
//         key: const Key('TOP_NAVIGATION'),
//         inAnimation: AdaptiveScaffold.bottomToTop,
//         outAnimation: AdaptiveScaffold.topToBottom,
//         builder: (context) {
//           return IntrinsicHeight(
//             child: AppBar(
//               toolbarHeight: 96,
//               titleSpacing: 0,
//               centerTitle: false,
//               leadingWidth: 0,
//               elevation: 0,
//               scrolledUnderElevation: 0,
//               automaticallyImplyLeading: false,
//               // title: _buildSearchBar(context),
//               actions: const [
//                 AttemptsActionButton(),
//                 StreakActionButton(),
//                 NotificationsActionButton(),
//                 SizedBox(width: 48.0),
//               ],
//             ),
//           );
//         },
//       ),
//     };
//   }
//
// // Widget _buildSearchBar(BuildContext context) {
// //   return TextFormField(
// //     maxLines: 1,
// //     expands: false,
// //     onChanged: (value) {},
// //     style: Omnes.w500.getStyle(
// //       fontSize: 16,
// //       color: context.colorScheme.onSurface,
// //     ),
// //     decoration: InputDecoration(
// //       constraints: const BoxConstraints(
// //         minHeight: 48,
// //         maxWidth: 400,
// //       ),
// //       contentPadding: const EdgeInsets.all(8.0),
// //       filled: true,
// //       fillColor: context.colorScheme.primary.withValues(alpha: 0.06),
// //       border: SmoothInputBorder(
// //         borderRadius: BorderRadius.circular(8.0),
// //       ),
// //       enabledBorder: SmoothInputBorder(
// //         borderRadius: BorderRadius.circular(8.0),
// //         borderSide: BorderSide.none,
// //       ),
// //       prefixIconConstraints:
// //           const BoxConstraints.tightFor(width: 40, height: 40),
// //       prefixIcon: Padding(
// //         padding: const EdgeInsetsDirectional.only(
// //           top: 8.0,
// //           bottom: 8.0,
// //           start: 16.0,
// //           end: 8.0,
// //         ),
// //         child: SizedBox.square(
// //           dimension: 16.0,
// //           child: SvgPicture.asset(
// //             Svgs.search,
// //             colorFilter: context.colorScheme.primary.toColorFilter(),
// //           ),
// //         ),
// //       ),
// //       hintText: "search...".tr(),
// //       hintStyle: Omnes.w500.getStyle(
// //         fontSize: 16,
// //         color: context.colorScheme.primary.withValues(alpha: 0.6),
// //       ),
// //     ),
// //   );
// // }
// }
