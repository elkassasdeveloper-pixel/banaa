import 'package:educ_student/screens/learn/learn_cubit.dart';
import 'package:educ_student/screens/learn/topics_list.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LearnScreenMobile extends StatelessWidget {
  const LearnScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LearnCubit, LearnState>(
      builder: (context, state) {
        final cubit = context.read<LearnCubit>();

        return TopicsList(
          key: cubit.listKey,
          onRefresh: () => cubit.onRefresh(context),
          // onTopicChanged: cubit.refreshUi,
        );
      },
    );
  }
}
