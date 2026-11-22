import 'package:educ_core/data/models/topic.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/helpers.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
import 'package:educ_student/core/assets.dart';
import 'package:educ_student/core/routes.dart';
import 'package:educ_student/core/brand_colors.dart';
import 'package:educ_student/screens/topic_details/topic_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TopicBookmarkTile extends StatelessWidget {
  const TopicBookmarkTile({
    super.key,
    required this.topic,
    required this.fetchAllTopics,
  });

  final Topic topic;
  final Future<void> Function() fetchAllTopics;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
          shape: const SmoothRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          color: context.colorScheme.surfaceContainerLowest,
          shadows: [
            BoxShadow(
              color: context.colorScheme.surfaceContainer.withValues(alpha: 0.7),
              blurRadius: 20,
              offset: const Offset(2, 4),
            ),
          ]),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => context.pushNamed(
            Routes.TOPIC,
            pathParameters: {
              "topicId": topic.id,
            },
            extra: topic.toMap(),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 21 / 9,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            shape: SmoothRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                          child: topic.files.isNotEmpty
                              ? _buildImage(topic.files.first.fileName, context)
                              : _buildEmptyImage(context),
                        ),
                      ),
                      PositionedDirectional(
                        top: 8,
                        start: 8,
                        child: BlocProvider(
                          create: (context) => TopicCubit(topic: topic),
                          child: BlocBuilder<TopicCubit, TopicState>(
                            builder: (context, state) {
                              final cubit = context.read<TopicCubit>();
                              return IconButton(
                                onPressed: () {
                                  cubit.topic = topic;
                                  cubit.removeBookmark(topic.id).then(
                                        (value) => fetchAllTopics(),
                                      );
                                  /* Topic */ /*DetailsScreen.fromId(topicId: topic.id);*/
                                },
                                icon: SvgPicture.asset(
                                  Svgs.bookmarkFilled,
                                  colorFilter: BrandColors.primary1.toColorFilter(),
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: context.colorScheme.surfaceContainerLow,
                                  foregroundColor: BrandColors.primary1,
                                  fixedSize: const Size.square(32.0),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        topic.name,
                        style: Omnes.w700.getStyle(
                          fontSize: 16.0,
                          color: context.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: topic.collectionName,
                            ),
                            // bullet
                            const TextSpan(
                              text: "  •  ",
                            ),
                            TextSpan(
                              text: formatMinutes(calculateReadingTime(topic.content)),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.start,
                        style: Omnes.w400.getStyle(
                          fontSize: 14,
                          color: context.colorScheme.onSurface.alphaBlend(
                            context.colorScheme.surface,
                            0.7,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                            Svgs.ionBookOutline,
                            colorFilter: context.colorScheme.onSurface.withValues(alpha: 0.7).toColorFilter(),
                          ),
                          const SizedBox(width: 4.0),
                          Expanded(
                            child: Text(
                              topic.description,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: Omnes.w400.getStyle(
                                fontSize: 14.0,
                                color: context.colorScheme.onSurface.alphaBlend(context.colorScheme.surface, 0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String image, BuildContext context) {
    return CachedNetworkImage(
      imageUrl:Uri.encodeFull(image),
      memCacheWidth: 300,
      imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
      fit: BoxFit.cover,
      placeholder: (c, s) {
        return Container(
          color: context.colorScheme.surfaceContainer,
        );
      },
      errorWidget: (context, url, error) {
        return Container(
          color: context.colorScheme.surfaceContainerHighest,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.error, color: context.colorScheme.error),
              const SizedBox(height: 8.0),
              Text(
                "errors.unable_to_load_image".tr(),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyImage(BuildContext context) {
    return Container(
      color: context.colorScheme.surfaceContainer,
    );
  }
}
