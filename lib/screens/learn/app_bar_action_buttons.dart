import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_student/core/assets.dart';
import 'package:educ_student/core/extensions.dart';
import 'package:educ_student/screens/auth/auth_cubit.dart';
import 'package:educ_student/screens/profile/profile_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

ButtonStyle _appBarActionButtonStyle(BuildContext context) {
  return TextButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    foregroundColor: context.theme.iconTheme.color,
  );
}

class StreakActionButton extends StatelessWidget {
  const StreakActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final cubit = context.read<ProfileCubit>();
        return Tooltip(
          message: "streak".tr(),
          child: TextButton.icon(
            onPressed: () {},
            label: Text(
              (cubit.profile?.streak ?? 0).toString(),
              style: Omnes.w500
                  .getStyle(fontSize: 24, color: context.colors.headline),
            ),
            icon: SvgPicture.asset(
              Svgs.thunder,
              width: 24,
              height: 24,
              colorFilter: context.colors.headline.toColorFilter(),
            ),
            style: _appBarActionButtonStyle(context),
          ),
        );
      },
    );
  }
}

class AttemptsActionButton extends StatelessWidget {
  const AttemptsActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final cubit = context.read<AuthCubit>();
        return Tooltip(
          message: "attempts".tr(),
          child: TextButton.icon(
            onPressed: () {},
            label: Text(
              cubit.accountAttempts.toString(),
              style: Omnes.w500
                  .getStyle(fontSize: 24, color: context.colors.headline),
            ),
            icon: SvgPicture.asset(
              Svgs.attemptsHeart,
              width: 24,
              height: 24,
            ),
            style: _appBarActionButtonStyle(context),
          ),
        );
      },
    );
  }
}

class NotificationsActionButton extends StatelessWidget {
  const NotificationsActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {},
      tooltip: "notifications".tr(),
      color: context.colors.headline,
      icon: SvgPicture.asset(
        Svgs.notification,
        width: 24,
        height: 24,
        colorFilter: context.colors.headline.toColorFilter(),
      ),
      style: _appBarActionButtonStyle(context),
    );
  }
}
