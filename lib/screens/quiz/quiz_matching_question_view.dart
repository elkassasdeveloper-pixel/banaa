import 'dart:developer';

import 'package:educ_core/data/models/question/question.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/services/cache_helper.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/logger.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
import 'package:educ_student/core/brand_colors.dart';
import 'package:educ_student/screens/quiz/quiz_cubit.dart';
import 'package:educ_student/widgets/custom_audio_player.dart';
import 'package:educ_student/widgets/custom_video_player.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'i_quiz_cubit.dart';

class QuizMatchingQuestionView extends StatelessWidget {
  const QuizMatchingQuestionView({
    super.key,
    required this.question,
    required this.answerResult,
  });

  final MatchingQuestion question;
  final AnswerResult answerResult;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
              () {
            if (question.fileType != '' && question.fileType != '') {
              switch (question.fileType) {
                case 'i':
                  return _buildMediaImage(context, question.fileUrl);
                case 'v':
                  return _buildMediaVideo(context, question.fileUrl);
                case 'a':
                  return _buildMediaAudio(context, question.fileUrl);
                default:
                  log(
                    "Unsupported Media Type, media url: ${question.fileType}",
                  );
                  // return Text('unsupported_media_type'.tr(args: [mediaName]));
                  return const SizedBox.shrink();
              }
            } else {
              return const SizedBox.shrink();
            }
          }(),
          Text(
            question.questionBody,
            style: Omnes.w700.getStyle(fontSize: 20),
          ),
          const SizedBox(height: 16),
          _buildAnswers(context),
        ],
      ),
    );
  }
  Widget _buildAnswers(BuildContext context) {
    // final answerResult = context.select((QuizCubit c) => c.currentAnswerResult);
    final hasPermissionsToSeeCorrect = CacheHelper.getPermissionsToSeeCorrect() ?? false;

    final answerResult = context.watch<QuizCubit>().currentAnswerResult;

    final quizCubit = context.read<QuizCubit>();
    final matches = question.userAnswer?.matches ?? <int, int>{};
    final aValues = question.userAnswer?.aValues;
    final bValues = question.userAnswer?.bValues;

    if (aValues == null || bValues == null) return const SizedBox();

    Map<Color, Color> colors = {
      BrandColors.primary1: Colors.black,
      BrandColors.primary2: Colors.white,
      BrandColors.primary4: Colors.black,
      BrandColors.secondary1: Colors.black,
      BrandColors.secondary2: Colors.black,
    };

    List<String?> flattenedAnswers = [];
    for (var i = 0; i < question.answers.length; i++) {
      flattenedAnswers.add(aValues[i]);
      flattenedAnswers.add(bValues[i]);
    }

    int? getA(int bIndex) {
      final fromUser = matches.entries.firstWhereOrNull((e) => e.value == bIndex)?.key;

      final shouldShowCorrect = (answerResult == AnswerResult.wrong || answerResult == AnswerResult.timeOut) && hasPermissionsToSeeCorrect;
      if (fromUser == null && shouldShowCorrect) {
        for (int i = 0; i < question.answers.length; i++) {
          if (question.answers[i].b == bValues[bIndex]) return i;
        }
      }
      return fromUser;
    }

    bool shouldHighlightCorrectA(int aIndex) {
      final shouldShowCorrect = (answerResult == AnswerResult.wrong || answerResult == AnswerResult.timeOut) && hasPermissionsToSeeCorrect;
      final userMatched = matches.containsKey(aIndex);
      return shouldShowCorrect && !userMatched;
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        mainAxisExtent: 60,
      ),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: flattenedAnswers.length,
      itemBuilder: (context, index) {
        final isA = index % 2 == 0;
        final columnIndex = index ~/ 2;

        if (isA) {
          final valueA = flattenedAnswers[index];
          final number = columnIndex + 1;
          final colorMap = colors.entries.toList()[columnIndex];

          final isSelected = question.userAnswer?.currentSelectedA == columnIndex;
          final isFocused = question.userAnswer?.currentSelectedA == null ? null : isSelected;
          final isMatched = matches.keys.contains(columnIndex);
          final highlightCorrect = shouldHighlightCorrectA(columnIndex);

          return MatchingItemWidget(
            matched: isMatched || highlightCorrect,
            focused: isFocused,
            selected: isSelected,
            number: number,
            color: colorMap.key,
            textColor: colorMap.value,
            label: valueA??'',
            onSelected: () => quizCubit.onMatchingSelectedA(question, columnIndex),
          );
        } else {
          final valueB = flattenedAnswers[index];
          final number = columnIndex + aValues.length + 1;
          final aIndex = getA(columnIndex);
          final colorMap = aIndex != null ? colors.entries.toList()[aIndex] : null;

          return MatchingItemWidget(
            selected: false,
            focused: true,
            matched: aIndex != null,
            number: number,
            color: colorMap?.key,
            textColor: colorMap?.value,
            label: valueB??'',
            onSelected: () => quizCubit.onMatchingSelectedB(question, columnIndex),
          );
        }
      },
    );
  }

/*
  Widget _buildAnswers(BuildContext context) {
    Map<Color, Color> colors = {
      BrandColors.primary1: Colors.black,
      BrandColors.primary2: Colors.white,
      // BrandColors.primary3: Colors.black,
      BrandColors.primary4: Colors.black,
      BrandColors.secondary1: Colors.black,
      BrandColors.secondary2: Colors.black,
      // BrandColors.primary1.darken(50): Colors.white,
      // // BrandColors.primary2.darken(10): Colors.black,
      // // BrandColors.primary3.darken(10): Colors.black,
      // BrandColors.primary4.darken(50): Colors.white,
      // BrandColors.secondary1.darken(50): Colors.white,
      // BrandColors.secondary2.darken(50): Colors.white,
    };

    final quizCubit = context.read<QuizCubit>();
    final matches = question.userAnswer?.matches ?? <int, int>{};
    final aValues = question.userAnswer?.aValues;
    final bValues = question.userAnswer?.bValues;
    final flattenedAnswers = [];

    for (var i = 0; i < question.answers.length; i++) {
      flattenedAnswers.add(aValues?[i]);
      flattenedAnswers.add(bValues?[i]);
    }

    if (aValues == null || bValues == null) return const SizedBox();

    int? getA(int b) {
      return matches.entries.firstWhereOrNull((e) => e.value == b)?.key;
    }

    // int right = 1;
    // int left = flattenedAnswers.length ~/ 2;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        mainAxisExtent: 60,
      ),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: flattenedAnswers.length,
      itemBuilder: (context, index) {
        final isA = index % 2 == 0;

        final columnIndex = (index ~/ 2);

        if (isA) {
          // int number = index + right;
          // right--;
          int number = (index ~/ 2) + 1;
          final valueA = flattenedAnswers[index];
          final colorMap = colors.entries.toList()[number - 1];

          final selectedA = question.userAnswer?.currentSelectedA;

          final bool isSelected = selectedA == columnIndex;
          bool? isFocused = selectedA == null ? null : isSelected;

          return MatchingItemWidget(
            matched: matches.keys.contains(columnIndex),
            focused: isFocused,
            selected: isSelected,
            number: number,
            color: colorMap.key,
            textColor: colorMap.value,
            label: valueA,
            onSelected: () => quizCubit.onMatchingSelectedA(question, columnIndex),
          );
        } else {
          // int number = index + left;
          // left--;
          int number = ((index - 1) ~/ 2) + ((flattenedAnswers.length ~/ 2) + 1);

          final valueB = flattenedAnswers[index];
          final aIndex = getA(columnIndex);
          final colorMap = aIndex != null ? colors.entries.toList()[aIndex] : null;

          return MatchingItemWidget(
            selected: false,
            focused: true,
            matched: aIndex != null,
            number: number,
            color: colorMap?.key,
            textColor: colorMap?.value,
            label: valueB,
            onSelected: () => quizCubit.onMatchingSelectedB(question, columnIndex),
          );
        }
      },
    );

return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: aValues.length,
            separatorBuilder: (context, index) {
              return const SizedBox(height: 12);
            },
            itemBuilder: (context, index) {
              final valueA = aValues[index];

              final selectedA = question.userAnswer?.currentSelectedA;

              final bool isSelected = selectedA == index;
              bool? isFocused = selectedA == null ? null : isSelected;

              return MatchingItemWidget(
                matched: matches.keys.contains(index),
                focused: isFocused,
                selected: isSelected,
                number: index + 1,
                color: colors.entries.toList()[index % colors.length].key,
                textColor: colors.entries.toList()[index % colors.length].value,
                label: valueA,
                onSelected: () =>
                    quizCubit.onMatchingSelectedA(question, index),
              );
            },
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bValues.length,
            separatorBuilder: (context, index) {
              return const SizedBox(height: 12);
            },
            itemBuilder: (context, index) {
              final valueB = bValues[index];
              final aIndex = getA(index);

              return MatchingItemWidget(
                selected: false,
                focused: true,
                matched: aIndex != null,
                number: aValues.length + index + 1,
                color: aIndex != null
                    ? colors.entries.toList()[aIndex % colors.length].key
                    : null,
                textColor: aIndex != null
                    ? colors.entries.toList()[aIndex % colors.length].value
                    : null,
                label: valueB,
                onSelected: () =>
                    quizCubit.onMatchingSelectedB(question, index),
              );
            },
          ),
        ),
      ],
    );

  }
*/
//-------------------------------------
/*Widget _buildAnswers(BuildContext context) {
    final quizCubit = context.read<QuizCubit>();
    final matches = question.userAnswer?.matches ?? <int, int>{};
    final aValues = question.userAnswer?.aValues;
    final bValues = question.userAnswer?.bValues;

    if (aValues == null || bValues == null) return const SizedBox();

    int? getAIndexOf(int b) {
      return matches.entries.firstWhereOrNull((e) => e.value == b)?.key;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: aValues.length,
            separatorBuilder: (context, index) {
              return const SizedBox(height: 12);
            },
            itemBuilder: (context, index) {
              final valueA = aValues[index];

              final selectedA = question.userAnswer?.currentSelectedA;

              final bool isSelected = selectedA == index;
              bool? isFocused = selectedA == null ? null : isSelected;

              return MatchingItemWidget(
                matched: matches.keys.contains(index),
                focused: isFocused,
                selected: isSelected,
                number: index + 1,
                color: _colors.entries.toList()[index % _colors.length].key,
                textColor:
                    _colors.entries.toList()[index % _colors.length].value,
                label: valueA,
                onSelected: () =>
                    quizCubit.onMatchingSelectedA(question, index),
              );
            },
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bValues.length,
            separatorBuilder: (context, index) {
              return const SizedBox(height: 12);
            },
            itemBuilder: (context, index) {
              final valueB = bValues[index];
              final aIndex = getAIndexOf(index);

              return MatchingItemWidget(
                selected: false,
                focused: true,
                matched: aIndex != null,
                number: aValues.length + index + 1,
                color: aIndex != null
                    ? _colors.entries.toList()[aIndex % _colors.length].key
                    : null,
                textColor: aIndex != null
                    ? _colors.entries.toList()[aIndex % _colors.length].value
                    : null,
                label: valueB,
                onSelected: () =>
                    quizCubit.onMatchingSelectedB(question, index),
              );
            },
          ),
        ),
      ],
    );
  }*/

  Widget _buildMediaImage(BuildContext context, String url) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: context.colorScheme.surface,
        shape: SmoothRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
      child: CachedNetworkImage(
        imageUrl:Uri.encodeFull(url),
        memCacheWidth: 300,
        imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
        fit: BoxFit.fitWidth,
        alignment: Alignment.center,
        errorListener: (value) {
          Logger.Red(value);
        },
        imageBuilder: (context, imageProvider) {
          return AspectRatio(
            aspectRatio: 16 / 9,
            child: Image(image: imageProvider, fit: BoxFit.cover),
          );
        },
        errorWidget: (context, url, error) {
          return const SizedBox.shrink();
          // return Opacity(
          //   opacity: 0.2,
          //   child: Container(
          //     padding: const EdgeInsets.all(8.0),
          //     color: context.colorScheme.errorContainer.withValues(alpha: 0.3),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       crossAxisAlignment: CrossAxisAlignment.center,
          //       children: [
          //         Text(url.split('/').last),
          //         const SizedBox(width: 8.0),
          //         Icon(
          //           Icons.image_not_supported_rounded,
          //           color: context.colorScheme.error,
          //         ),
          //       ],
          //     ),
          //   ),
          // );
        },
      ),
    );
  }

  Widget _buildMediaVideo(BuildContext context, String url) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.black,
        shape: SmoothRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: CustomVideoPlayer(url: url),
      ),
    );
  }

  Widget _buildMediaAudio(BuildContext context, String url) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: SmoothRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: CustomAudioPlayer(url: url),
    );
  }
}

class MatchingItemWidget extends StatelessWidget {
  const MatchingItemWidget({
    super.key,
    required this.number,
    required this.label,
    required this.color,
    required this.textColor,
    required this.matched,
    required this.focused,
    required this.selected,
    required this.onSelected,
  });

  final int number;
  final String label;
  final Color? color;
  final Color? textColor;
  final bool matched;
  final bool? focused;
  final bool selected;
  final VoidCallback onSelected;

  Color get colorOrTrans => color ?? Colors.transparent;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(8.0);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 100),
      opacity: focused == null || focused == true ? 1.0 : 0.6,
      child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 100),
          tween: Tween(begin: selected ? 0.0 : 1.0, end: selected ? 1.0 : 0.0),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Material(
              type: MaterialType.button,
              color: _getBackgroundColor(context),
              shape: SmoothRectangleBorder(
                borderRadius: borderRadius,
                side: BorderSide(
                  color: _getBorderColor(context).withValues(alpha: value),
                  width: value * 2,
                  strokeAlign: value * 4,
                ),
              ),
              child: InkWell(
                borderRadius: borderRadius,
                onTap: onSelected,
                child: Container(
                  alignment: Alignment.center,
                  constraints: const BoxConstraints(minHeight: 56),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: _getBackgroundColor(context),
                    borderRadius: borderRadius,
                    boxShadow: [
                      BoxShadow(
                        color: matched ? color?.darken(30) ?? Colors.transparent : Colors.transparent,
                        blurRadius: 0,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            label,
                            style: Omnes.w500.getStyle(
                              fontSize: 14,
                              color: matched ? textColor : context.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    /*if (selected) {
      return _colors[number % _colors.length];
    } else */
    if (matched && color != null) {
      return color!;
    } else {
      return context.colorScheme.surface;
    }
  }

  Color _getBorderColor(BuildContext context) {
    /*if (selected) {
      return _colors[number % _colors.length];
    } else */
    if (selected && color != null) {
      return color!;
    } else {
      return Colors.transparent;
    }
  }
}
