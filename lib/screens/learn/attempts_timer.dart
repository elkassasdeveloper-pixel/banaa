import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_student/core/extensions.dart';
import 'package:educ_student/screens/auth/auth_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttemptsTimer extends StatelessWidget {
  const AttemptsTimer({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
      valueListenable: context.read<AuthCubit>().attemptsCountdown,
      builder: (context, seconds, _) {
        if (seconds == null) return const SizedBox.shrink();

        final label =
            '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';

        return Padding(
          padding: const EdgeInsetsDirectional.only(end: 4),
          child: Text(
            label,
            style: Omnes.w500.getStyle(
              fontSize: 24,
              color: context.colors.headline,
            ),
          ),
        );
      },
    );
  }
}