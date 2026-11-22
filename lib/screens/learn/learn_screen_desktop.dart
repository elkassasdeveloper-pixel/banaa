// import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
//
// class LearnScreenDesktop extends StatelessWidget {
//   const LearnScreenDesktop({super.key});
//
//   static const bodyRatio = 0.6;
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<LearnCubit, LearnState>(
//         builder: (context, state) {
//           final cubit = context.read<LearnCubit>();
//           final topics = cubit.topics;
//
//           return AdaptiveLayout(
//             bodyRatio: bodyRatio,
//             topNavigation: const LearnDesktopTopNavigation(),
//             body: const LearnDesktopBody(),
//             secondaryBody: context.isLarge ? const LearnDesktopSecondaryBody() : null,
//           );
//         }
//     //,
//     );
//
//   }
// }
