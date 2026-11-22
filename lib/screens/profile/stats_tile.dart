import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
import 'package:educ_student/core/assets.dart';
import 'package:material_ui/material_ui.dart';

class StatsTile extends StatelessWidget {
  final Text title;
  final String iconPath;
  final Text value;

  const StatsTile({
    super.key,
    required this.title,
    required this.iconPath,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: 56.0,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        shape: SmoothRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(
            strokeAlign: BorderSide.strokeAlignInside,
            color: context.colorScheme.tertiaryContainer,
            width: 2,
          ),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -2,
            bottom: -4,
            child: SvgPicture.asset(
              Svgs.statsTileDecorationRight,
              colorFilter:
                  context.colorScheme.tertiaryContainer.toColorFilter(),
            ),
          ),
          Positioned(
            left: -2,
            bottom: -4,
            child: SvgPicture.asset(
              Svgs.statsTileDecorationLeft,
              colorFilter:
                  context.colorScheme.tertiaryContainer.toColorFilter(),
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DefaultTextStyle(
                  style: Omnes.w700.getStyle(
                      fontSize: 20,
                      color: context.colorScheme.tertiaryContainer
                          .alphaBlend(context.colorScheme.surface, 0.7)),
                  child: title,
                ),
                const SizedBox(width: 16.0),
                DefaultTextStyle(
                  style: Montserrat.w700.getStyle(
                      fontSize: 20,
                      color: context.colorScheme.tertiaryContainer),
                  child: value,
                ),
                const SizedBox(width: 4.0),
                SvgPicture.asset(
                  iconPath,
                  width: 20,
                  height: 20,
                  colorFilter:
                      context.colorScheme.tertiaryContainer.toColorFilter(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
