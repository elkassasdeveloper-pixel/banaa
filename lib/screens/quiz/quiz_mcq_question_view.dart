import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:educ_core/data/models/question/question.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/services/cache_helper.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/logger.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
import 'package:educ_student/widgets/custom_audio_player.dart';
import 'package:educ_student/widgets/custom_video_player.dart';
import 'package:educ_student/widgets/banaa_button.dart';
import 'package:material_ui/material_ui.dart';

import 'i_quiz_cubit.dart';

final _autoSizeGroup = AutoSizeGroup();

class QuizMcqQuestionView extends StatelessWidget {
  const QuizMcqQuestionView({super.key, required this.question, required this.onAnswerSelected, this.answerResult});

  final MultipleChoiceQuestion question;
  final void Function(MultipleChoiceQuestion question, McqQuestionAnswer answer) onAnswerSelected;
  final AnswerResult? answerResult;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                  log("Unsupported Media Type, media url: ${question.fileType}");
                  // return Text('unsupported_media_type'.tr(args: [mediaName]));
                  return const SizedBox.shrink();
              }
            } else {
              return const SizedBox.shrink();
            }
          }(),
          Text(question.questionBody, style: Omnes.w700.getStyle(fontSize: 20)),
          const SizedBox(height: 16),
          ListView.separated(
            itemCount: question.answers.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, answerIndex) {
              final answer = question.answers[answerIndex];
              final userSelected = question.userAnswer?.selectedAnswer;
              final isCorrectAnswer = answer.isCorrect;
              final isSelectedAnswer = userSelected?.body == answer.body;

              final isWrong = answerResult == AnswerResult.wrong;
              final isTimeOut = answerResult == AnswerResult.timeOut;
              final isConfirmed = answerResult != AnswerResult.none;

              // Show green highlight only *after* confirmation if the answer is correct
              final hasPermissionsToSeeCorrect = CacheHelper.getPermissionsToSeeCorrect() ?? false;
              final shouldHighlightCorrect = (isWrong || isTimeOut) && isCorrectAnswer && isConfirmed && hasPermissionsToSeeCorrect;

              // Show selected answer normally
              if (isSelectedAnswer) {
                return BanaaButton.accent(onPressed: () => onAnswerSelected(question, answer), label: answer.body, accentColor: context.colorScheme.tertiaryContainer, autoSizeGroup: _autoSizeGroup, maxLines: 2);
              }

              // Highlight correct answer *after confirmation*
              if (shouldHighlightCorrect) {
                return BanaaButton.accent(onPressed: () {}, label: answer.body, accentColor: Colors.green, autoSizeGroup: _autoSizeGroup, maxLines: 2);
              }

              // Default case
              return BanaaButton.accentSurface(onPressed: () => onAnswerSelected(question, answer), label: answer.body, autoSizeGroup: _autoSizeGroup, accentColor: context.colorScheme.primary, maxLines: 2);

            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 12);
            },
          ),
        ],
      ),
    );
  }

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
        color: Colors.black,
        shape: SmoothRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
      padding: const EdgeInsets.all(8),
      child: CustomAudioPlayer(url: url),
    );
  }
}
