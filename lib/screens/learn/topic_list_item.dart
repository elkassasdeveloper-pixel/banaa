import 'package:auto_size_text/auto_size_text.dart';
import 'package:educ_core/data/models/topic.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/helpers.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
import 'package:educ_student/core/assets.dart';
import 'package:educ_student/core/routes.dart';
import 'package:educ_student/core/brand_colors.dart';
import 'package:educ_student/core/extensions.dart';
import 'package:educ_student/screens/auth/auth_cubit.dart';
import 'package:educ_student/screens/learn/learn_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TopicListItem extends StatelessWidget {
  TopicListItem({
    super.key,
    required this.topic,
    required this.horizontalPosition,
    this.isCentered = false,
  });

  final Topic topic;
  final int horizontalPosition;
  final bool isCentered;

  final GlobalKey painterKey = GlobalKey();

  static const int maxPositions = 2;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
      child: Row(
        children: List.generate(
          isCentered ? 3 : maxPositions,
          // 2,
          (i) => buildItem(context, i),
        ),
      ),
    );
  }

  Widget buildItem(BuildContext context, int i) {
    int pos = horizontalPosition;
    if (isCentered) {
      pos = 1;
    }

    if (i == pos) {
      return Expanded(
        key: painterKey,
        child: Align(
          alignment: Alignment.center,
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 300,
            ),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: context.colors.background,
              shape: SmoothRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  width: 1,
                  color: topic.isFinished ? BrandColors.secondary1 : context.colors.outline,
                ),
              ),
              shadows: [
                BoxShadow(
                  color: topic.isFinished ? BrandColors.secondary1.darken(20) : context.colors.bgShadow,
                  blurRadius: 0,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                )
              ],
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                highlightColor:
                    (topic.isFinished ? BrandColors.secondary1 : BrandColors.primary1).withValues(alpha: 0.2),
                onTap: () async {
                  await context
                      .pushNamed(
                    Routes.TOPIC,
                    pathParameters: {
                      'topicId': topic.id,
                    },
                    extra: topic.toMap(),
                  )
                      .whenComplete(() {
                    Future.wait([
                      if(context.mounted)  context.read<LearnCubit>().refreshTopics(),
                      if(context.mounted)  context.read<AuthCubit>().fetchUser(),
                    ]);
                  }).then(
                    (value) {
                      if (value == false) {
                        if(context.mounted)   context.pushNamed(Routes.TASBEEH);
                      }
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        topic.isFinished ? Svgs.cloudMoonGreen : Svgs.cloudMoonBlue,
                        width: 30,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              topic.name,
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                              style: Omnes.w700.getStyle(
                                fontSize: 16,
                                color: context.colors.headline,
                              ),
                              softWrap: true,
                            ),
                            Flexible(
                              child: AutoSizeText(
                                formatMinutes(topic.calculateReadingTime()),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                minFontSize: 10,
                                maxFontSize: 12,
                                style: Omnes.w500.getStyle(
                                  fontSize: 12,
                                  color: context.colors.bodyText,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (topic.isFinished)
                        const Icon(
                          Icons.check_circle,
                          color: BrandColors.secondary1,
                        )
                      else
                        SizedBox.square(
                          dimension: 16,
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 500),
                            tween: Tween(
                              begin: 0.0,
                              end: topic.isOpened ? 0.5 : 0.0,
                            ),
                            builder: (context, value, child) {
                              return CircularProgressIndicator(
                                value: value,
                                color: BrandColors.primary1.withValues(alpha: 0.5),
                                backgroundColor: context.colors.iconContainer,
                                strokeAlign: BorderSide.strokeAlignCenter,
                                strokeCap: StrokeCap.round,
                                strokeWidth: 4,
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: isCentered ? 15 : 50,
      height: 0,
    );
  }
}
