import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
import 'package:educ_student/screens/post/post_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ImagesCarouselSlider extends StatelessWidget {
  const ImagesCarouselSlider({
    super.key,
    required this.pageController,
    required this.cubit,
    required this.images,
    this.aspectRatio = 16 / 9,
  });

  final PageController pageController;
  final PostCubit cubit;
  final List<String> images;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostCubit, PostState>(
      bloc: cubit,
      builder: (context, state) {
        return AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              shape: SmoothRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: images.length > 1
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(
                        child: IntrinsicHeight(
                          child: PageView.builder(
                            controller: pageController,
                            restorationId: cubit.postId,
                            itemCount: images.length,
                            onPageChanged: cubit.onPageChanged,
                            itemBuilder: (context, index) {
                              return _buildImage(images[index], context);
                            },
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        end: 8,
                        bottom: 8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            images.length,
                            (index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 1.0,
                                ),
                                width: cubit.getIndicatorWidth(
                                    index, images.length, pageController),
                                height: 4.0,
                                decoration: ShapeDecoration(
                                  shape: const StadiumBorder(),
                                  color: cubit.page(pageController).round() ==
                                          index
                                      ? Colors.white
                                      : Colors.white60,
                                ),
                              );
                            },
                          ).toList(),
                        ),
                      ),
                    ],
                  )
                : _buildImage(images[0], context),
          ),
        );
      },
    );
  }

  CachedNetworkImage _buildImage(String image, BuildContext context) {
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
}
