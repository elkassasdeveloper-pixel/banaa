import 'dart:developer';

import 'package:educ_core/data/models/question/question.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/services/cache_helper.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/logger.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
import 'package:educ_student/core/extensions.dart';
import 'package:educ_student/screens/quiz/i_quiz_cubit.dart';
import 'package:educ_student/widgets/custom_audio_player.dart';
import 'package:educ_student/widgets/custom_video_player.dart';
import 'package:material_ui/material_ui.dart';

class QuizFillQuestionView extends StatelessWidget {
  const QuizFillQuestionView({super.key, required this.question, required this.onAnswerAdded, required this.onAnswerRemoved, required this.answerResult});

  final FillQuestion question;
  final void Function(FillQuestion question, int slotIndex, String answer) onAnswerAdded;
  final void Function(FillQuestion question, int slotIndex, String answer) onAnswerRemoved;
  final AnswerResult answerResult;

  static const draggableItemPadding = EdgeInsets.symmetric(horizontal: 18, vertical: 14);

  @override
  Widget build(BuildContext context) {
    final hasPermissions = CacheHelper.getPermissionsToSeeCorrect() ?? false;
    final showAnswer = hasPermissions && (answerResult == AnswerResult.wrong || answerResult == AnswerResult.timeOut);

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
          const Divider(),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            // alignment: WrapAlignment.center,
            // runAlignment: WrapAlignment.center,
            children: _buildCorrectAnswerChips(context),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Text("من الخيارات التالية ", style: Omnes.w700.getStyle(fontSize: 20)),
          const SizedBox(height: 16),
          const SizedBox(height: 16),
          Wrap(alignment: WrapAlignment.center, runAlignment: WrapAlignment.center, spacing: 8, runSpacing: 8, children: _buildAnswersChips(context)),
          if (showAnswer) _buildHighlightedCorrectSentence(context),
        ],
      ),
    );
  }
  Widget _buildHighlightedCorrectSentence(BuildContext context) {
    final correctWords = question.correctAnswers;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: RichText(
        text: TextSpan(
          children: correctWords.map((word) {
            final style = word.isReplaceable
                ? Omnes.w600.getStyle(fontSize: 16, color: Colors.green.shade800)
                : Omnes.w500.getStyle(fontSize: 16, color: context.colorScheme.onSurface);

            return TextSpan(text: '${word.body} ', style: style);
          }).toList(),
        ),
      ),
    );
  }
  List<Widget> _buildAnswersChips(BuildContext context) {
    return question.userAnswer?.shuffledAnswers.map((e) {
          return _buildDraggableAnswerChip(context, e);
        }).toList() ??
        [];
  }

  Draggable<String> _buildDraggableAnswerChip(BuildContext context, String answer, {VoidCallback? onPressed}) {
    final label = Text(answer, style: Omnes.w500.getStyle(fontSize: 16.0, color: context.colorScheme.onSurface));

    final chip = Material(
      type: MaterialType.transparency,
      child: RawChip(
        label: label,
        padding: draggableItemPadding,
        tapEnabled: onPressed != null,
        onPressed: onPressed,
        shape: SmoothRectangleBorder(
          side: BorderSide(width: 2, color: context.colors.outline),
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: context.colors.shapeContainer,
        elevation: 2,
        shadowColor: context.colors.bodyText.lighten(10),
      ),
    );

    return Draggable<String>(
      data: answer,
      feedback: chip,
      childWhenDragging: Chip(
        label: Opacity(opacity: 0, child: label),
        padding: draggableItemPadding,
        shape: SmoothRectangleBorder(
          side: BorderSide(width: 2, color: context.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: chip,
    );
  }

  List<Widget> _buildCorrectAnswerChips(BuildContext context) {
    // final correctAnswers = question.correctAnswers;
    const padding = EdgeInsets.symmetric(horizontal: 18, vertical: 14);
    const paddingEmpty = EdgeInsets.symmetric(horizontal: 22, vertical: 14);

    return question.correctAnswers.mapIndexed((index, answer) {
      if (answer.isReplaceable) {
        final userAnswer = question.userAnswer;
        if (userAnswer != null) {
          final value = userAnswer.filledWords[index];
          if (value != null) {
            return _buildDraggableAnswerChip(
              context,
              value,
              onPressed: () {
                onAnswerRemoved(question, index, value);
              },
            );
          }
        }
        return DragTarget<String>(
          onAcceptWithDetails: (details) {
            onAnswerAdded(question, index, details.data);
          },
          builder: (context, candidateData, rejectedData) {
            bool isOver = candidateData.isNotEmpty;
            return RawChip(
              tapEnabled: false,
              label: const Opacity(opacity: .8, child: Text("...........")),
              padding: paddingEmpty,
              shape: SmoothRectangleBorder(
                side: BorderSide(width: 2, color: context.colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: isOver ? context.colorScheme.outlineVariant.lighten(10) : context.colorScheme.outlineVariant,
            );
          },
        );
      }
      return RawChip(
        label: Text(answer.body, softWrap: true, maxLines: 3, style: Omnes.w500.getStyle(fontSize: 16.0, color: context.colorScheme.onSurface.withValues(alpha: 0.7))),
        padding: padding,
        shape: SmoothRectangleBorder(
          side: BorderSide(width: 2, color: context.colorScheme.outlineVariant.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.transparent,
      );
    }).toList();
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
