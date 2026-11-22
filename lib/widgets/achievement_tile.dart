import 'package:educ_core/data/models/achievement.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
import 'package:educ_student/core/assets.dart';
import 'package:material_ui/material_ui.dart';

class AchievementTile extends StatelessWidget {
  const AchievementTile({super.key, required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120.0,
      padding: const EdgeInsets.all(16.0),
      decoration: ShapeDecoration(
        color: context.colorScheme.surfaceContainerLow,
        shape: SmoothRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(
            color: context.colorScheme.primary,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              achievement.title,
              style: Omnes.w500.getStyle(fontSize: 20.0, color: context.colorScheme.primary),
            ),
          ),
          const SizedBox(width: 8.0),
          AspectRatio(
            aspectRatio: 1,
            child: _buildImage(achievement.fileName, context),
          ),
        ],
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
          decoration: ShapeDecoration(
            color: context.colorScheme.surfaceContainerHighest,
            shape: SmoothRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
          child: Center(
            child: SvgPicture.asset(
              width: 32.0,
              height: 32.0,
              Svgs.achievementCup,
              colorFilter: context.colorScheme.primary.withValues(alpha: 0.3).toColorFilter(),
            ),
          ),
        );
      },
    );
  }
}
