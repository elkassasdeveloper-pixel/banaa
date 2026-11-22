import 'package:educ_core/data/models/topic.dart';
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
import 'package:educ_student/core/routes.dart';
import 'package:educ_student/screens/auth/auth_cubit.dart';
import 'package:educ_student/screens/learn/learn_cubit.dart';
import 'package:educ_student/screens/main_screen.dart';
import 'package:educ_student/screens/quiz/quiz_cubit.dart';
import 'package:educ_student/screens/topic_details/topic_cubit.dart';
import 'package:educ_student/widgets/custom_video_player.dart';
import 'package:educ_student/widgets/banaa_button.dart';
import 'package:educ_student/widgets/responsive_layout.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class TopicDetailsScreen extends StatelessWidget {
  TopicDetailsScreen({super.key, required Topic this.topic}) : topicId = topic.id;

  const TopicDetailsScreen.fromId({super.key, required this.topicId}) : topic = null;

  final String topicId;
  final Topic? topic;

  // static Topic? nextTopic;

  static const _floatingButtonHeight = 80.0;
  static const extendedNavigationRailWidth = 240.0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final topic = this.topic;
        if (topic != null) {
          return TopicCubit(topic: topic);
        }
        return TopicCubit.fromId(topicId);
      },
      child: BlocConsumer<TopicCubit, TopicState>(
        listener: (context, state) {
          final cubit = context.read<TopicCubit>();
          if (state is TopicError) {
            context.showFailureSnackBar(state.failure);
          } else if (state is TopicAddBookmarkSuccess) {
            context.showSuccessSnackBar("topic_added_to_bookmarks".tr());
            syncTopicWithLearnScreen(context, cubit);
          } else if (state is TopicRemoveBookmarkSuccess) {
            context.showNormalSnackBar("topic_removed_from_bookmarks".tr());
            syncTopicWithLearnScreen(context, cubit);
          }
        },
        builder: (context, state) {
          final cubit = context.read<TopicCubit>();
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              leadingWidth: 120,
              leading: Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: context.pop,
                  icon: SvgPicture.asset(
                    Svgs.backArrow,
                    colorFilter: context.colorScheme.primary.toColorFilter(),
                    matchTextDirection: true,
                  ),
                  label: Text("back".tr()),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    // minimumSize: const Size(48, 30),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () => cubit.shareTopic(context),
                  icon: SvgPicture.asset(
                    Svgs.share2,
                    colorFilter: context.colorScheme.primary.toColorFilter(),
                  ),
                ),
              ],
            ),
            floatingActionButton: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                _buildFloatingQuizButton(context, cubit.isButtonVisible, cubit.topic?.quizPoints),
                buildAssistantWidget(context),
              ],
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButtonAnimator: const NoAnimationFabMotionAnimator(),
            // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            // floatingActionButton: _buildFloatingQuizButton(context, cubit.isButtonVisible, cubit.topic?.quizPoints),
            body: NotificationListener<ScrollNotification>(
              onNotification: cubit.onScrollNotification,
              child: RefreshIndicator.adaptive(
                onRefresh: () async {
                  await Future.wait([cubit.fetchTopic(), context.read<QuizCubit>().fetchQuiz()]);
                },
                child: ResponsiveLayout(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(
                            top: 16.0,
                            bottom: 120.0,
                            left: 16.0,
                            right: 16.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildTopicRootCollectionName(context, cubit),
                              const SizedBox(height: 12),
                              _buildTopicHeader(context, cubit, state),
                              const SizedBox(height: 16),
                              _buildActionsButtonBar(context, cubit.topic?.quizPoints),
                              const SizedBox(height: 16),
                              _buildTopicMediaWidgets(context, cubit, state),
                              const SizedBox(height: 16),
                              _buildTopicContent(),
                            ],
                          ),
                        ),
                      ),
                      // _buildFloatingQuizButton(context, cubit.isButtonVisible,
                      //     cubit.topic?.quizPoints)
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void syncTopicWithLearnScreen(BuildContext context, TopicCubit cubit) {
    try {
      final t = context.read<LearnCubit>().updateTopic(topicId, cubit.topic!);
      if (t != null) {
        t.isBookmarked = true;
      }
    } catch (_) {}
  }

  Widget _buildFloatingQuizButton(BuildContext context, bool isButtonVisible, int? quizPoints) {
    return ResponsiveLayout(
      alignment: Alignment.bottomCenter,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: _floatingButtonHeight,
          maxHeight: _floatingButtonHeight * 1.2,
        ),
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: context.colors.container,
          shape: const SmoothRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          shadows: [
            BoxShadow(
              color: context.colorScheme.shadow.withValues(alpha: 0.3),
              offset: const Offset(0, -2),
              blurRadius: 8,
            ),
          ],
        ),
        child: BanaaButton(
          onPressed: () => _goToQuizScreen(context),
          label: "start_topic_quiz".tr(args: [(quizPoints ?? 0).toString()]),
          maxLines: 1,
        ),
      ),
    );
  }

  Widget _buildTopicRootCollectionName(BuildContext context, TopicCubit cubit) {
    return Text(
      cubit.topic?.rootCollectionName ?? "",
      textAlign: TextAlign.center,
      style: Omnes.w500.getStyle(
        fontSize: 14,
        color: context.colorScheme.onSurface.alphaBlend(context.colorScheme.surface, 0.7),
      ),
    );
  }

  Widget _buildTopicHeader(BuildContext context, TopicCubit cubit, TopicState state) {
    if (state is TopicLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          cubit.topic?.name ?? "",
          textAlign: TextAlign.center,
          style: Omnes.w700.getStyle(fontSize: 20, color: context.colorScheme.primary),
        ),
        const SizedBox(height: 12),
        Text(
          cubit.topic?.description ?? "",
          textAlign: TextAlign.center,
          style: Omnes.w400.getStyle(
            fontSize: 16,
            color: context.colorScheme.onSurface.alphaBlend(context.colorScheme.surface, 0.6),
          ),
        ),
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: cubit.topic?.collectionName),
              // bullet
              const TextSpan(text: "  •  "),
              TextSpan(text: formatMinutes(cubit.topic?.calculateReadingTime() ?? 0)),
            ],
          ),
          textAlign: TextAlign.center,
          style: Omnes.w400.getStyle(
            fontSize: 14,
            color: context.colorScheme.onSurface.alphaBlend(context.colorScheme.surface, 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildActionsButtonBar(BuildContext context, int? quizPoints) {
    return OverflowBar(
      alignment: MainAxisAlignment.center,
      spacing: 8.0,
      overflowSpacing: 8.0,
      children: [
        _buildBookmarkButton(context),
      ],
    );
  }

  Widget _buildBookmarkButton(BuildContext context) {
    return BlocBuilder<TopicCubit, TopicState>(
      builder: (context, state) {
        final cubit = context.read<TopicCubit>();

        final topic = cubit.topic;
        if (topic == null) {
          return const SizedBox.shrink();
        }

        bool isLoading = state is TopicBookmarkLoading;

        final foregroundColor = isLoading
            ? Colors.grey
            : topic.isBookmarked
            ? BrandColors.primary1
            : context.colorScheme.primary;

        return IconButton(
          onPressed: isLoading ? null : () => cubit.toggleBookmark(topicId),
          icon: SvgPicture.asset(
            topic.isBookmarked ? Svgs.bookmarkDoneFilled : Svgs.bookmarkOutlined,
            colorFilter: foregroundColor.toColorFilter(),
          ),
          style: IconButton.styleFrom(
            backgroundColor: context.colorScheme.surfaceContainerLow,
            foregroundColor: foregroundColor,
          ),
        );
      },
    );
  }

  Widget _buildTopicContent() {
    return BlocBuilder<TopicCubit, TopicState>(
      builder: (context, state) {
        final cubit = context.read<TopicCubit>();
        if (state is TopicLoading || cubit.topic == null) {
          return const SizedBox.shrink();
        } else {
          final topic = cubit.topic;
          if (topic != null) {
            QuillController controller = QuillController(
              document: topic.getContentAsDocument() ?? Document(),
              selection: const TextSelection.collapsed(offset: 0),
              readOnly: true,
            );

            // return QuillEditor.basic(
            //   controller: controller,
            //   configurations: QuillEditorConfigurations(
            //     controller: controller,
            //     scrollPhysics: const NeverScrollableScrollPhysics(),
            //     enableInteractiveSelection: false,
            //   ),
            // );
            return QuillEditor.basic(
              controller: controller,
              config: const QuillEditorConfig(
                enableInteractiveSelection: false,
                scrollPhysics: NeverScrollableScrollPhysics(),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        }
      },
    );
  }

  Widget _buildTopicMediaWidgets(BuildContext context, TopicCubit cubit, TopicState state) {
    final topic = cubit.topic;
    if (state is TopicLoading || topic == null) {
      return const SizedBox.shrink();
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: topic.files.length,
      itemBuilder: (context, index) {
        final file = topic.files[index];
        final mediaType = MediaType.getMediaType(url: file.fileName);
        // final mediaName = getMediaName(file);
        switch (mediaType) {
          case MediaType.image:
            return _buildMediaImage(context, file.fileName);
          case MediaType.video:
            return _buildMediaVideo(context, file.fileName);
          case MediaType.audio:
            return _buildMediaAudio();
          case MediaType.other:
            // log("Unsupported Media Type, media url: $file");
            // return Text('unsupported_media_type'.tr(args: [mediaName]));
            return const SizedBox.shrink();
        }
      },
      separatorBuilder: (context, index) {
        return const SizedBox(height: 16);
      },
    );
  }

  Widget _buildMediaImage(BuildContext context, String url) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: context.colorScheme.surfaceContainerLow,
        shape: SmoothRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: CachedNetworkImage(
          imageUrl: Uri.encodeFull(url),
          memCacheWidth: 300,
          imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          errorListener: (value) {
            Logger.Red(value);
          },
          imageBuilder: (context, imageProvider) {
            return Image(image: imageProvider, fit: BoxFit.cover);
          },
          progressIndicatorBuilder: (context, url, downloadProgress) {
            return Center(
              child: CircularProgressIndicator(
                value: downloadProgress.progress,
              ),
            );
          },
          errorWidget: (context, url, error) {
            return Center(
              child: Icon(
                Icons.image_not_supported_rounded,
                size: 36,
                color: context.colorScheme.error,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMediaVideo(BuildContext context, String url) {
    return Container(
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

  Widget _buildMediaAudio() => const Text('Audio Widget Placeholder');

  Future<void> _goToQuizScreen(BuildContext context) async {
    if(  context.read<AuthCubit>().accountAttempts == 0) {
      Logger.Red("accountAttempts: ${context.read<AuthCubit>().accountAttempts}");
      //her i want Show Dialog
      _showNoAttemptsDialog(context);
    }else{
    context.pushNamed(Routes.QUIZ, pathParameters: {"topicId": topicId});
  }}

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
                context.pop();
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
  // void updateNextTopic(BuildContext context, String topicId) {
  //   try {
  //     final learnCubit = context.read<LearnCubit>();
  //     final values = learnCubit.getTopicAndNextTopic(topicId);
  //     TopicDetailsScreen.nextTopic = values.nextTopic;
  //     Logger.data("Next Topic ID", values.nextTopic?.id);
  //   } catch (e) {
  //     Logger.Red("Couldn't get next topic");
  //     if (kDebugMode) {
  //       print(e);
  //     }
  //   }
  // }
}
