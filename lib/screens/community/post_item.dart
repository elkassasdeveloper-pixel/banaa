import 'dart:convert';

import 'package:educ_core/data/models/post.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/educ_core.dart' as quill;
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/helpers.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_student/core/assets.dart';
import 'package:educ_student/core/routes.dart';
import 'package:educ_student/core/extensions.dart';
import 'package:educ_student/screens/post/post_cubit.dart';
import 'package:educ_student/widgets/images_carousel_slider.dart';
import 'package:educ_student/widgets/read_more_text.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PostItem extends StatelessWidget {
  const PostItem({super.key, required this.pageController, this.cubit, this.isExpanded = false});

  final PageController pageController;
  final PostCubit? cubit;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit, PostState>(
      bloc: cubit,
      listener: (context, state) {
        if (state is PostErrorState && !isExpanded) {
          context.showFailureSnackBar(state.failure);
        }
      },
      builder: (context, state) {
        final cubit = context.read<PostCubit>();
        final post = cubit.post;

        if (post == null) {
          return const SizedBox.shrink();
        }

        return Hero(
          tag: post.id,
          child: Material(
            color: context.colors.background,
            child: InkWell(
              onTap: _goToPostScreen(context, post),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      minLeadingWidth: 40.0,
                      leading: Container(
                        width: 40.0,
                        height: 40.0,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: context.colorScheme.surfaceContainer),
                        foregroundDecoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: context.colorScheme.outlineVariant, width: 1.0, strokeAlign: BorderSide.strokeAlignInside, style: BorderStyle.solid),
                        ),
                        child: CachedNetworkImage( imageUrl:Uri.encodeFull(post.author.authorFileName),
                            memCacheWidth: 300,
                            imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet, height: 40.0, width: 40.0, fit: BoxFit.cover, errorWidget: (_, _, _) => const SizedBox(), placeholder: (_, _) => const SizedBox()),
                      ),
                      title: Text(post.author.authorFullName, style: Omnes.w700.getStyle(fontSize: 16.0, color: context.colorScheme.primary)),
                      trailing: Text(
                        "time_ago".tr(args: [formatDateTimeFromNow(convertCairoNonDSTToLocal(post.createdAt))]),
                        style: Omnes.w400.getStyle(fontSize: 14.0, color: context.colorScheme.primary.withValues(alpha: 0.5)),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Expanded(
                      flex: isExpanded ? 1 : 0,
                      child: SingleChildScrollView(
                        physics: isExpanded ? null : const NeverScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (post.body.isNotEmpty)
                              Builder(
                                builder: (context) {
                                  try {
                                    final doc = quill.Document.fromJson(jsonDecode(post.body));
                                    final controller = quill.QuillController(document: doc, selection: const TextSelection.collapsed(offset: 0));

                                    return IgnorePointer(
                                      child: quill.QuillEditor.basic(
                                        controller: controller,
                                        //  readOnly: true,
                                      ),
                                    );
                                  } catch (e) {
                                    // fallback to plain text if invalid JSON
                                    return ReadMoreText(isExpanded: isExpanded, text: post.body);
                                  }
                                },
                              ),
                            // ReadMoreText(isExpanded: isExpanded, text: post.body),
                            if (post.files.isNotEmpty) ...[const SizedBox(height: 8.0), ImagesCarouselSlider(pageController: pageController, cubit: cubit, images: post.files.map((e) => e.fileName).toList())],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextButtonTheme(
                      data: TextButtonThemeData(
                        style: context.theme.textButtonTheme.style?.copyWith(foregroundColor: WidgetStatePropertyAll(context.colorScheme.primary), visualDensity: VisualDensity.compact, tapTargetSize: MaterialTapTargetSize.padded, padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0)), textStyle: WidgetStatePropertyAll(Omnes.w400.getStyle(fontSize: 16.0))),
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          TextButton.icon(
                            onPressed: state is PostLikeLoading || state is PostUnlikeLoading ? null : cubit.toggleLike,
                            icon: SvgPicture.asset(post.isLiked ? Svgs.likeFilled : Svgs.likeOutlined, colorFilter: post.isLiked ? null : context.colorScheme.primary.toColorFilter()),
                            label: Text(_getLikesCountText(post.likesCount)),
                          ),
                          TextButton.icon(
                            onPressed: () => cubit.sharePost(context),
                            icon: SvgPicture.asset(Svgs.share2, colorFilter: context.colorScheme.primary.toColorFilter()),
                            label: Text(_getSharesCountText(post.sharesCount)),
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
      },
    );
  }

  VoidCallback? _goToPostScreen(BuildContext context, Post post) {
    if (isExpanded) return null;
    return () => context.pushNamed(Routes.POST, pathParameters: {'postId': post.id}, extra: {'cubit': context.read<PostCubit>()});
  }

  String _getLikesCountText(int likesCount) {
    final value = formatIntegerRecord(likesCount);
    return "${value.number} ${value.unit}";
  }

  String _getSharesCountText(int sharesCount) {
    final value = formatIntegerRecord(sharesCount);
    return "${value.number} ${value.unit}";
  }
}
