import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_student/screens/group/group_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupAboutTab extends StatelessWidget {
  const GroupAboutTab({super.key});

  @override
  Widget build(BuildContext context) {
    final groupCubit = context.read<GroupCubit>();
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: 16.0,
        bottom: 120.0,
        left: 16.0,
        right: 16.0,
      ),
      child: Text(
        groupCubit.group?.description.toString() ?? "",
        style: Omnes.w400.getStyle(
          fontSize: 14.0,
          color: context.colorScheme.primary,
        ),
      ),
    );
  }
}
