import 'package:auto_size_text/auto_size_text.dart';
import 'package:educ_core/data/models/group.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/logger.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
import 'package:educ_student/core/brand_colors.dart';
import 'package:educ_student/core/constants.dart';
import 'package:educ_student/core/extensions.dart';
import 'package:educ_student/core/routes.dart';
import 'package:educ_student/screens/community/community_groups_cubit.dart';
import 'package:educ_student/screens/post/popular_posts_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GroupItem extends StatelessWidget {
  final Group group;

  const GroupItem({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Logger.Green("groupId: ${group.id}");
        Logger.Green("group: ${group.toMap()}");
        context
            .pushNamed(Routes.GROUP, pathParameters: {"groupId": group.id}, extra: group.toMap())
            .then(
              (value) => Future.wait([
                if(context.mounted) context.read<CommunityGroupsCubit>().fetchGroups(),
                if(context.mounted) context.read<PopularPostsCubit>().fetchPopularPosts(),
              ]),
            );
        Strings.groupId = group.id;
      },
      child: SizedBox(
        width: 80.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: BrandColors.primary2,
                  shape: SmoothRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  shadows: [
                    BoxShadow(
                      color: context.isDark
                          ? BrandColors.primary2.lighten(5)
                          : BrandColors.primary2.darken(10),
                      blurRadius: 0,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                foregroundDecoration: ShapeDecoration(
                  shape: SmoothRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: const BorderSide(color: BrandColors.primary2),
                  ),
                ),
                child: CachedNetworkImage(
                  fit: BoxFit.fill,
                  imageUrl:Uri.encodeFull(group.fileName),
                  memCacheWidth: 300,
                  imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
                  errorWidget: (context, url, error) {
                    return const SizedBox.shrink();
                  },
                  placeholder: (context, url) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Flexible(
              child: AutoSizeText(
                group.name,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: Omnes.w400.getStyle(fontSize: 18, color: context.colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
