// import 'package:educ_core/educ_core.dart';
// import 'package:educ_core/utils/extensions.dart';
// import 'package:educ_core/utils/text_styles.dart';
// import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
// import 'package:educ_student/core/assets.dart';
// import 'package:educ_student/core/extensions.dart';
// import 'package:material_ui/material_ui.dart';
// import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
//
// class LearnDesktopSecondaryBody extends SlotLayout {
//   const LearnDesktopSecondaryBody({super.key}) : super(config: const {});
//
//   @override
//   Map<Breakpoint, SlotLayoutConfig?> get config {
//     return {
//       Breakpoints.standard: SlotLayout.from(
//         key: const Key('LEARN_DESKTOP_SECONDARY_BODY'),
//         inAnimation: AdaptiveScaffold.fadeIn,
//         outAnimation: AdaptiveScaffold.fadeOut,
//         builder: (context) {
//           return SingleChildScrollView(
//             padding: const EdgeInsetsDirectional.only(
//               start: 24.0,
//               end: 48.0,
//               top: 24.0,
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 _buildCard(
//                   context,
//                   icon: Svgs.thunderFilled,
//                   bgColor:
//                       context.colorScheme.tertiaryContainer.withValues(alpha: 0.1),
//                   title: "learn_card_1_title".tr(namedArgs: {
//                     "streak": (context.user?.streak ?? 0).toString(),
//                   }),
//                   description: "learn_card_1_description".tr(),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     };
//   }
//
//   Widget _buildCard(
//     BuildContext context, {
//     required String icon,
//     required Color bgColor,
//     required String title,
//     required String description,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(24.0),
//       decoration: ShapeDecoration(
//         color: bgColor,
//         shape: const SmoothRectangleBorder(
//           borderRadius: BorderRadius.all(Radius.circular(16.0)),
//         ),
//       ),
//       child: Row(
//         children: [
//           SizedBox.square(
//             dimension: 64.0,
//             child: SvgPicture.asset(
//               icon,
//               width: 64.0,
//               height: 64.0,
//               colorFilter: context.colors.headline.toColorFilter(),
//             ),
//           ),
//           const SizedBox(width: 16.0),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: Omnes.w600
//                       .getStyle(fontSize: 18, color: context.colors.headline),
//                 ),
//                 const SizedBox(height: 8.0),
//                 Text(
//                   description,
//                   style: Omnes.w500.getStyle(
//                     fontSize: 14,
//                     color: context.colors.bodyText.withValues(alpha: 0.6),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
