import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
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

void _showContextualGuidanceDialog(
  BuildContext context, {
  required String titleKey,
  required String descKey,
  Widget? headerIcon,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: context.colorScheme.surfaceContainerLow,
      shape: SmoothRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (headerIcon != null) ...[
            headerIcon,
            const SizedBox(height: 12),
          ],
          Text(
            titleKey.tr(),
            textAlign: TextAlign.center,
            style: Omnes.w700.getStyle(fontSize: 18, color: context.colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Text(
            descKey.tr(),
            textAlign: TextAlign.center,
            style: Omnes.w400.getStyle(fontSize: 14, color: context.colorScheme.onSurface),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text("ok".tr(), style: Omnes.w500.getStyle(fontSize: 14)),
        ),
      ],
    ),
  );
}

class StreakActionButton extends StatelessWidget {
  const StreakActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final cubit = context.read<ProfileCubit>();
        final streakCount = cubit.profile?.streak ?? 0;
        return Tooltip(
          message: "streak_tooltip".tr(),
          child: TextButton.icon(
            onPressed: () {
              _showContextualGuidanceDialog(
                context,
                titleKey: "streak_guidance_title",
                descKey: "streak_guidance_desc",
                headerIcon: SvgPicture.asset(
                  Svgs.thunder,
                  width: 48,
                  height: 48,
                  colorFilter: context.colors.headline.toColorFilter(),
                ),
              );
            },
            label: Text(
              streakCount.toString(),
              style: Omnes.w500.getStyle(fontSize: 24, color: context.colors.headline),
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
          message: "attempts_tooltip".tr(),
          child: TextButton.icon(
            onPressed: () {
              _showContextualGuidanceDialog(
                context,
                titleKey: "attempts_guidance_title",
                descKey: "attempts_guidance_desc",
                headerIcon: SvgPicture.asset(
                  Svgs.attemptsHeart,
                  width: 48,
                  height: 48,
                ),
              );
            },
            label: Text(
              cubit.accountAttempts.toString(),
              style: Omnes.w500.getStyle(fontSize: 24, color: context.colors.headline),
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
    return Tooltip(
      message: "notifications_tooltip".tr(),
      child: IconButton(
        onPressed: () {
          _showContextualGuidanceDialog(
            context,
            titleKey: "notifications",
            descKey: "notifications_tooltip",
            headerIcon: SvgPicture.asset(
              Svgs.notification,
              width: 48,
              height: 48,
              colorFilter: context.colors.headline.toColorFilter(),
            ),
          );
        },
        color: context.colors.headline,
        icon: SvgPicture.asset(
          Svgs.notification,
          width: 24,
          height: 24,
          colorFilter: context.colors.headline.toColorFilter(),
        ),
        style: _appBarActionButtonStyle(context),
      ),
    );
  }
}
