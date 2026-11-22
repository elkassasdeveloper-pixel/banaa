import 'package:educ_core/utils/extensions.dart';
import 'package:educ_student/assistant_cubit.dart';
import 'package:educ_student/screens/learn/learn_cubit.dart';
import 'package:educ_student/screens/learn/learn_screen_mobile.dart';
import 'package:educ_student/widgets/custom_adaptive_layout.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LearnCubit()),
        BlocProvider(create: (context) => AssistantCubit(appEventCode: 10)),
      ],
      child: BlocListener<LearnCubit, LearnState>(
        listener: (context, state) {
          if (state is LearnTopicsError) {
            context.showFailureSnackBar(state.failure);
          } else if (state is LearnCollectionsError) {
            context.showFailureSnackBar(state.failure);
          }
        },
        child: CustomAdaptiveLayout(
          smallBody: (context) {
            return const LearnScreenMobile();
          },
          mediumBody: (context) {
            return const LearnScreenMobile();
          },
          largeBody: (context) {
            return const LearnScreenMobile(); //LearnScreenDesktop();
          },
          // mediumLargeBody: (context) {
          //   return const LearnScreenMobile();
          // },
        ),
      ),
    );
  }
}
