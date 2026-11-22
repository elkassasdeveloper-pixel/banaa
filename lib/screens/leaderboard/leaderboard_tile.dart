import 'package:educ_core/data/models/leaderboard_entry.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
import 'package:educ_student/core/assets.dart';
import 'package:material_ui/material_ui.dart';

class LeaderboardTile extends StatelessWidget {
  const LeaderboardTile({
    super.key,
    required this.rank,
    required this.entry,
    required this.isHighlighted,
  });

  final int rank;
  final LeaderboardEntry entry;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isHighlighted
        ? context.colorScheme.onSurface
        : context.colorScheme.onSurface;

    final rankSvg = switch (rank) {
      1 => Svgs.rank1,
      2 => Svgs.rank2,
      3 => Svgs.rank3,
      _ => null,
    };
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        selected: isHighlighted,
        selectedTileColor:
            context.colorScheme.tertiaryContainer.withValues(alpha: 0.15),
        tileColor: null,
        shape: SmoothRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        title: Text(
          entry.fullName,
          style: Omnes.w700.getStyle(
            color: foregroundColor,
          ),
        ),
        subtitle: Text(
          entry.biography,
          style: Omnes.w700.getStyle(
            fontSize: 12.0,
            color: foregroundColor.withValues(alpha: 0.7),
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: 24.0,
              child: Center(
                child: rankSvg != null
                    ? SvgPicture.asset(rankSvg)
                    : Text(
                        rank.toString(),
                        style: Omnes.w700.getStyle(
                          color: context.colorScheme.tertiaryContainer,
                          fontSize: 14.0,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 48,
              height: 48,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: context.colorScheme.tertiaryContainer.alphaBlend(
                  context.colorScheme.surface,
                  isHighlighted ? 0.5 : 0.15,
                ),
                shape: SmoothRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              foregroundDecoration: ShapeDecoration(
                shape: SmoothRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: isHighlighted
                      ? BorderSide.none
                      : BorderSide(
                          color: context.colorScheme.tertiaryContainer
                              .withValues(alpha: 0.3),
                          strokeAlign: BorderSide.strokeAlignOutside,
                          width: 1.0,
                        ),
                ),
              ),
              child: CachedNetworkImage(
                  imageUrl:Uri.encodeFull(entry.avatarFileName),
                  imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                  width: 48,
                  height: 48,
                  memCacheWidth: 92,
                  memCacheHeight: 92,
                  errorWidget: (context, url, error) {
                    return Icon(
                      Icons.person,
                      color: context.colorScheme.tertiary,
                    );
                  },
                  placeholder: (context, url) {
                    return Icon(
                      Icons.person,
                      color: context.colorScheme.tertiary,
                    );
                  }),
            ),
          ],
        ),
        trailing: Text(
          "${entry.score}\n${"point".tr()}",
          textAlign: TextAlign.center,
          style: Omnes.w700.getStyle(
            fontSize: 12.0,
            color: foregroundColor,
          ),
        ),
      ),
    );
  }
}
