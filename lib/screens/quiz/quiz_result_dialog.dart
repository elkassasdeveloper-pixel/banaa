import 'package:auto_size_text/auto_size_text.dart';
import 'package:educ_core/data/models/topic.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/helpers.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
import 'package:educ_student/assistant_cubit.dart';
import 'package:educ_student/core/assets.dart';
import 'package:educ_student/core/brand_colors.dart';
import 'package:educ_student/core/extensions.dart';
import 'package:educ_student/core/routes.dart';
import 'package:educ_student/screens/main_screen.dart';
import 'package:educ_student/widgets/banaa_button.dart';
import 'package:educ_student/widgets/responsive_layout.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class QuizResultDialog extends StatelessWidget {
  const QuizResultDialog({
    super.key,
    required this.score,
    required this.percentage,
    required this.time,
    this.nextTopic,
    this.nextTopicId,
  }) : isAdvancedQuiz = false,
       onContinue = null,
       onRetry = null;

  const QuizResultDialog.advanced({
    super.key,
    required this.score,
    required this.percentage,
    required this.time,
    required this.onContinue,
    required this.onRetry,
  }) : isAdvancedQuiz = true,
       nextTopic = null,
       nextTopicId = null;

  final int score;
  final double percentage;
  final String time;
  final Topic? nextTopic;
  final String? nextTopicId;

  final bool isAdvancedQuiz;
  final void Function(bool isPassed)? onContinue;
  final VoidCallback? onRetry;

  bool get isPassed => score >= 70;

  bool get isAdvancedQuizFailed => isAdvancedQuiz && !isPassed;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AssistantCubit(appEventCode: isPassed ? 6 : 11),
      child: PopScope(
        canPop: true,
        child: Stack(
          alignment: AlignmentGeometry.bottomRight,
          children: [
            ResponsiveLayout(
              child: Dialog(
                backgroundColor: isAdvancedQuizFailed
                    ? context.colorScheme.errorContainer
                    : context.colorScheme.surfaceContainerLowest,
                shape: SmoothRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        heightFactor: 0.5,
                        alignment: Alignment.bottomCenter,
                        child: LottieBuilder.asset(
                          isAdvancedQuizFailed ? Lotties.warning : getLottiePathByScore(score),
                          //ahmed-2025-01-06
                          height: 180,
                          repeat: false,
                        ),
                      ),
                      if (isAdvancedQuizFailed)
                        Text(
                          "advanced_quiz_failed".tr(),
                          textAlign: TextAlign.center,
                          style: Omnes.w700.getStyle(
                            fontSize: 22,
                            color: context.colorScheme.onErrorContainer,
                          ),
                        )
                      else
                        Text(
                          context.user?.firstName != null || context.user?.firstName != ''
                              ? "you_finished_the_quiz".tr(
                                  namedArgs: {
                                    "first_name": context.user?.firstName ?? "friend".tr(),
                                  },
                                )
                              : "you_finished_the_quiz_visitor".tr(),
                          textAlign: TextAlign.center,
                          style: Omnes.w700.getStyle(
                            fontSize: 22,
                            color: context.colorScheme.primary,
                          ),
                        ),
                      const SizedBox(height: 8.0),
                      Text(
                        getPerformanceTextByScore(score),
                        textAlign: TextAlign.center,
                        style: Omnes.w500.getStyle(
                          fontSize: 16,
                          color: isAdvancedQuizFailed
                              ? context.colorScheme.onErrorContainer.withValues(alpha: 0.7)
                              : context.colors.bodyText,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          _buildResultBlock(context, time, Svgs.time),
                          const SizedBox(width: 8.0),
                          _buildResultBlock(context, "${percentage.toInt()}%", Svgs.target),
                          const SizedBox(width: 8.0),
                          _buildResultBlock(context, score.toString(), Svgs.achievementCup),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      if (!isAdvancedQuiz)
                        ..._buildStandardQuizOptions(context)
                      else
                        ..._buildAdvancedQuizOptions(context),
                    ],
                  ),
                ),
              ),
            ),
            if (isPassed)
              Positioned.fill(
                child: IgnorePointer(
                  child: LottieBuilder.asset(
                    Lotties.congratsJoy,
                    width: context.mediaQuery.size.width,
                    alignment: Alignment.bottomCenter,
                    fit: BoxFit.cover,
                    repeat: false,
                  ),
                ),
              ),
            buildAssistantWidget(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAdvancedQuizOptions(BuildContext context) {
    return [
      if (!isPassed) ...[_buildRetryButton(context), const SizedBox(height: 16.0)],
      _buildContinueButton(context),
    ];
  }

  List<Widget> _buildStandardQuizOptions(BuildContext context) {
    return [
      _buildNextTopicButton(context),
      const SizedBox(height: 16.0),
      BanaaButton.accentSurface(
        label: "return_to_the_main_page".tr(),
        accentColor: context.colorScheme.primary,
        onPressed: () {
          Navigator.pop(context);
          context.pushReplacementNamed(Routes.LEARN);
        },
      ),
    ];
  }

  Widget _buildResultBlock(BuildContext context, String label, String iconPath) {
    final color = isAdvancedQuizFailed
        ? context.colorScheme.outlineVariant
        : BrandColors.secondary1;

    return Expanded(
      child: Container(
        constraints: const BoxConstraints(minHeight: 48.0),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        decoration: ShapeDecoration(
          shape: SmoothRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: score <= 70 ? context.colorScheme.error : color, //ahmed-2025-01-06
              width: 1.5,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: AutoSizeText(
                label,
                minFontSize: 14,
                maxLines: 1,
                style: Omnes.w600.getStyle(
                  fontSize: 20,
                  color: score <= 70 ? context.colorScheme.error : color,
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            SvgPicture.asset(
              iconPath,
              width: 20,
              height: 20,
              colorFilter: score <= 70
                  ? context.colorScheme.error.toColorFilter()
                  : color.toColorFilter(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextTopicButton(BuildContext context) {
    final nextTopicId = this.nextTopicId;

    if (nextTopicId == null) {
      return const SizedBox.shrink();
    } else {
      return BanaaButton(
        label: "lets_go_to_the_next_lesson".tr(),
        onPressed: () async {
          final router = GoRouter.of(context);
          final extra = nextTopic?.toMap();
          Navigator.pop(context);
          router.goNamed(Routes.LEARN);
          router.pushNamed(
            Routes.TOPIC,
            pathParameters: {'topicId': nextTopicId},
            extra: extra,
          );
        },
      );
    }
  }

  String getPerformanceTextByScore(int score) {
    return switch (score) {
      <= 50 => "bad_performance".tr(),
      <= 70 => "you_can_do_better".tr(),
      <= 90 => "good_performance".tr(),
      _ => "excellent_performance".tr(),
    };
  }

  String getLottiePathByScore(int score) {
    return switch (score) {
      <= 70 => Lotties.badResult,
      _ => Lotties.congratsBadge,
    };
  } //ahmed-2025-01-06

  Widget _buildRetryButton(BuildContext context) {
    return BanaaButton.accentSurface(
      accentColor: context.colorScheme.primary,
      label: "retry_quiz".tr(),
      prefixIcon: const Icon(Icons.replay_outlined),
      onPressed: () {
        Navigator.pop(context);
        doPostFrame((_) {
          onRetry?.call();
        });
      },
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return BanaaButton.accent(
      accentColor: isPassed ? context.colorScheme.tertiary : context.colorScheme.primary,
      label: isPassed ? "continue".tr() : "continue_as_beginner".tr(),
      suffixIcon: isPassed ? null : const Icon(Icons.chevron_right),
      onPressed: () {
        Navigator.pop(context);
        doPostFrame((_) {
          onContinue?.call(isPassed);
        });
      },
    );
  }
}
