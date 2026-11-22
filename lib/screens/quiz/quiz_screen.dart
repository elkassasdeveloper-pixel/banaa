import 'package:educ_core/data/models/question/question.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/helpers.dart';
import 'package:educ_core/utils/logger.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
import 'package:educ_student/core/assets.dart';
import 'package:educ_student/core/assistant_fab_location.dart';
import 'package:educ_student/core/brand_colors.dart';
import 'package:educ_student/core/extensions.dart';
import 'package:educ_student/screens/auth/auth_cubit.dart';
import 'package:educ_student/screens/leaderboard/friends_leaderboard_cubit.dart';
import 'package:educ_student/screens/leaderboard/global_leaderboard_cubit.dart';
import 'package:educ_student/screens/learn/attempts_timer.dart';
import 'package:educ_student/screens/learn/learn_cubit.dart';
import 'package:educ_student/screens/main_screen.dart';
import 'package:educ_student/screens/profile/profile_cubit.dart';
import 'package:educ_student/screens/quiz/i_quiz_cubit.dart';
import 'package:educ_student/screens/quiz/quiz_fill_question_view.dart';
import 'package:educ_student/screens/quiz/quiz_matching_question_view.dart';
import 'package:educ_student/screens/quiz/quiz_mcq_question_view.dart';
import 'package:educ_student/screens/quiz/quiz_result_dialog.dart';
import 'package:educ_student/widgets/data_screen.dart';
import 'package:educ_student/widgets/banaa_button.dart';
import 'package:educ_student/widgets/loading_indicator.dart';
import 'package:educ_student/widgets/quiz_exit_dialog.dart';
import 'package:educ_student/widgets/responsive_layout.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class QuizScreen<C extends IQuizCubit> extends StatelessWidget {
  const QuizScreen({super.key, this.signUp});

  final Future<void> Function()? signUp;
  static const extendedNavigationRailWidth = 240.0;

  @override
  Widget build(BuildContext context) {
    return BlocListener<C, QuizState>(
      listener: (context, state) {
        if (state is QuizFinished) {
          final cubit = context.read<C>();
          _showQuizResultDialog(context, cubit, state);
        } else if (state is QuizResultError) {
          context.showFailureSnackBar(state.failure);
        }
      },
      child: DataScreen<C, QuizState>(
        fetch: (cubit) => cubit.initialize(),
        failure: (state) => state is QuizError
            ? state.failure
            : (state is QuizQuestionsError ? state.failure : null),
        isLoading: (state) => state is QuizLoading || state is QuizQuestionsLoading,
        isLoaded: (state) => state is QuizLoaded || state is QuizQuestionsLoaded,
        isEmpty: (cubit, state) => cubit.quiz == null && cubit.questions.isEmpty,
        buildWhen: (previous, current) {
          return current is! QuizQuestionCountdownUpdated;
        },
        builder: (context, cubit, state) {
          topicName = cubit.quiz?.name ?? '';
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop,result) {
              _onExit(context);
            },
            child: ResponsiveLayout(
              child: Scaffold(
                floatingActionButton:!cubit.isAdvanced ? buildAssistantWidget(context) : null,
                floatingActionButtonLocation:!cubit.isAdvanced ? AssistantFabLocation() : null,
                floatingActionButtonAnimator: !cubit.isAdvanced ? const NoAnimationFabMotionAnimator() : null,
                backgroundColor: Colors.transparent,
                body: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 80,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                _onExit(context);
                              },
                              tooltip: "close".tr(),
                              icon: const Icon(Icons.close_rounded),
                              color: context.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            _buildProgressIndicator(context),
                            if (!cubit.isAdvanced) ...[
                              const SizedBox(width: 8),
                              const AttemptsTimer(),
                              const SizedBox(width: 8),
                              _buildAttemptsCounter(context),
                            ],
                            const SizedBox(width: 16),
                          ],
                        ),
                      ),
                      _buildQuestionsPageView(context, state),
                    ],
                  ),
                ),
                bottomNavigationBar: _buildFooterContainer(context, state),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _onExit(BuildContext context, {bool showPopUp = true}) async {
    if (showPopUp == true) {
      await showDialog(
        context: context,
        builder: (context) {
          return const QuizExitDialog();
        },
      );
    } else {
      context.pop();
      context.pop();
      doPostFrame((_) {
        Navigator.pop(context, false);
      });
    }
  }

  Widget _buildQuestionsPageView(BuildContext context, QuizState state) {
    final cubit = context.read<C>();

    return Expanded(
      child: PageView.builder(
        controller: cubit.pageController,
        itemCount: cubit.questions.length,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: cubit.onPageChanged,
        itemBuilder: (context, index) {
          return IgnorePointer(
            ignoring: state is QuizAnswerConfirmed,
            child: SingleChildScrollView(child: _buildQuestion(context, state, index)),
          );
        },
      ),
    );
  }

  Widget _buildQuestion(BuildContext context, QuizState state, int questionIndex) {
    final cubit = context.read<C>();
    final question = cubit.questions[questionIndex];

    return switch (question) {
      MultipleChoiceQuestion() => QuizMcqQuestionView(
        question: question,
        onAnswerSelected: cubit.onMcqAnswerSelected,
        answerResult: cubit.currentAnswerResult,
      ),
      FillQuestion() => QuizFillQuestionView(
        question: question,
        onAnswerAdded: cubit.onFillAnswerAdded,
        onAnswerRemoved: cubit.onFillAnswerRemoved,
        answerResult: cubit.currentAnswerResult,
      ),
      MatchingQuestion() => QuizMatchingQuestionView(
        question: question,
        answerResult: cubit.currentAnswerResult,
      ),
    };
  }

  Widget _buildAttemptsCounter(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final cubit = context.read<AuthCubit>();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(Svgs.attemptsHeart),
            const SizedBox(width: 4),
            Text(
              cubit.accountAttempts.toString(),
              style: Omnes.w500.getStyle(fontSize: 24, color: context.colorScheme.primary),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    final cubit = context.read<C>();
    final currentPage = cubit.currentPageIndex + 1;
    final pagesCount = cubit.questions.length;

    return BlocBuilder<C, QuizState>(
      builder: (context, state) {
        bool isLastAnswerAndConfirmed = state is QuizAnswerConfirmed && currentPage == pagesCount;
        return Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                alignment: AlignmentDirectional.centerStart,
                children: [
                  Container(
                    height: 12,
                    decoration: ShapeDecoration(
                      shape: SmoothRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      color: context.colorScheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    height: 12,
                    width: constraints.maxWidth * (currentPage) / pagesCount,
                    alignment: Alignment.topCenter,
                    decoration: ShapeDecoration(
                      shape: SmoothRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      color: isLastAnswerAndConfirmed
                          ? BrandColors.secondary1
                          : context.colorScheme.primaryContainer,
                    ),
                    child: Divider(
                      thickness: 2,
                      indent: 4,
                      endIndent: 4,
                      height: 6,
                      color: isLastAnswerAndConfirmed
                          ? BrandColors.secondary1.lighten(25)
                          : BrandColors.primary3,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFooterContainer(BuildContext context, QuizState state) {
    final cubit = context.read<C>();
    bool isUnder10Seconds = cubit.timeLeft.inSeconds <= 10;
    return Container(
      decoration: ShapeDecoration(
        color: context.colors.container,
        // switch (cubit.currentAnswerResult) {
        //   AnswerResult.none => context.colorScheme.surfaceContainer,
        //   AnswerResult.correct => context.extendedColors.successContainer,
        //   AnswerResult.wrong => context.colorScheme.errorContainer.darken(20),
        //   AnswerResult.timeOut => context.colorScheme.errorContainer.darken(20),
        // },
        shape: const SmoothRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) {
              switch (cubit.currentAnswerResult) {
                case AnswerResult.correct:
                  return Row(
                    children: [
                      SvgPicture.asset(Svgs.check),
                      const SizedBox(width: 8),
                      Text(
                        "correct_answer".tr(),
                        style: Omnes.w700.getStyle(
                          fontSize: 20,
                          color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  );
                case AnswerResult.wrong:
                  return Row(
                    children: [
                      SvgPicture.asset(
                        Svgs.wrong,
                        // colorFilter: BrandColors.error.toColorFilter(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "wrong_answer".tr(),
                        style: Omnes.w700.getStyle(
                          fontSize: 20,
                          color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  );
                case AnswerResult.timeOut:
                  return Row(
                    children: [
                      SvgPicture.asset(
                        Svgs.wrong,
                        // colorFilter: BrandColors.error.toColorFilter(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "timeout".tr(),
                        style: Omnes.w700.getStyle(
                          fontSize: 20,
                          color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  );
                default:
                  return BlocBuilder<C, QuizState>(
                    buildWhen: (previous, current) {
                      return current is QuizQuestionCountdownUpdated;
                    },
                    builder: (context, state) {
                      return Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            color: isUnder10Seconds
                                ? BrandColors.error
                                : context.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            cubit.getTimeLeftFormatted(),
                            style: Montserrat.w700.getStyle(
                              fontSize: 20,
                              color: isUnder10Seconds
                                  ? BrandColors.error
                                  : context.colorScheme.primary,
                            ),
                          ),
                        ],
                      );
                    },
                  );
              }
            },
          ),
          const SizedBox(height: 8),
          BanaaButton.accent(
            isEnabled: cubit.isCurrentQuestionAnswered || state is QuizAnswerConfirmed,
            label: state is QuizAnswerConfirmed
                ? cubit.isLastPage
                      ? "finish_quiz".tr()
                      : "next".tr()
                : "confirm".tr(),
            onPressed: state is QuizAnswerConfirmed
                ? () => cubit.goToNextQuestion(cubit.score,cubit,context,_showNoAttemptsDialog /*//ahmed-2025-01-06*/)
                : () => _confirmAnswer(cubit, context),
            accentColor: switch (cubit.currentAnswerResult) {
              AnswerResult.correct => BrandColors.secondary1,
              AnswerResult.wrong => BrandColors.error,
              AnswerResult.timeOut => BrandColors.error,
              AnswerResult.none => null,
            },
          ),
        ],
      ),
    );
  }

  void _confirmAnswer(C cubit, BuildContext context) {
    final result = cubit.verifyCurrentAnswer();
    final totalAttempts = context.read<AuthCubit>().accountAttempts;
    try {
      if (result == true && !cubit.isAdvanced) {
        context.assistant.setEvent(8);
        context.assistant.start();
      } else if(!cubit.isAdvanced){
        context.assistant.setEvent(9);
        context.assistant.start();
      }
    } catch (e) {
      Logger.Red("Failed to show assistant bubble on correct answer: $e");
    }
    if (result == false && !cubit.isAdvanced && totalAttempts > 0) {
      context.read<AuthCubit>().decrementAccountAttempts(context: context);
      Logger.Green("accountAttempts: $totalAttempts");
    }
  }

  void _showNoAttemptsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {},
        child: AlertDialog(
          backgroundColor: context.colorScheme.surfaceContainerLow,
          shape: SmoothRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LottieBuilder.asset(
                Lotties.brokenHeart,
                height: 120,
                repeat: true,

                // reverse: true,
                // animate: true,
              ),
              const SizedBox(height: 16),
              Text(
                "no_attempts_left_message".tr(),
                textAlign: TextAlign.center,
                style: Omnes.w700.getStyle(fontSize: 20, color: context.colorScheme.primary),
              ),
              const SizedBox(height: 12),
              Text(
                "please_wait_to_restore_hearts".tr(),
                textAlign: TextAlign.center,
                style: Omnes.w400.getStyle(fontSize: 14, color: context.colorScheme.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                "then_try_the_quiz_again".tr(),
                textAlign: TextAlign.center,
                style: Omnes.w400.getStyle(fontSize: 14, color: context.colorScheme.onSurface),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                _onExit(context, showPopUp: false);
              },
              style: FilledButton.styleFrom(
                foregroundColor: context.colorScheme.onError,
                backgroundColor: context.colorScheme.error,
              ),
              child: Text("ok".tr(), style: Omnes.w500.getStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuizResultDialog(BuildContext context, C cubit, QuizState state) {
    if (!cubit.isAdvanced) {
      try {
        context.read<LearnCubit>().refreshTopics();
        context.read<ProfileCubit>().fetch();
        context.read<GlobalLeaderboardCubit>().fetchCurrentLeaderboard();
        context.read<FriendsLeaderboardCubit>().fetchCurrentLeaderboard();
      } catch (e, s) {
        Logger.error("Failed to call refresh methods", e, s);
      }
    }

    final nextTopicId = cubit.quiz?.nextTopicId;

    showDialog(
      context: context,
      useRootNavigator: false,
      barrierDismissible: false,
      builder: (_) {
        if (cubit.isAdvanced) {
          return QuizResultDialog.advanced(
            score: cubit.score,
            percentage: cubit.calculateResultPercentage(),
            time: cubit.getTotalQuizDurationFormatted(),
            onContinue: (passed) async {
              if (passed) {
                LoadingIndicator.show(context, () async {
                  await signUp?.call();

                  if (cubit.score > 70) {
                    //ahmed-2025-01-06
                    // context.assistant.stop();
                    // context.assistant.setEvent(6);
                    // context.assistant.start();
                    // context.assistant.showAssistantOverlay(rootContext);
                    cubit.finishQuiz();
                  } else {
                    // context.assistant.stop();
                    // context.assistant.setEvent(11);
                    // context.assistant.start();
                    // context.assistant.showAssistantOverlay(rootContext);
                  }
                });
              } else {
                await signUp?.call();
              }
            },
            onRetry: cubit.reloadQuiz,
          );
        }
        return QuizResultDialog(
          score: cubit.score,
          percentage: cubit.calculateResultPercentage(),
          time: cubit.getTotalQuizDurationFormatted(),
          nextTopicId: nextTopicId,
        );
      },
    );
  }
}
