import 'package:educ_core/data/models/collection.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
import 'package:educ_student/core/assets.dart';
import 'package:educ_student/core/brand_colors.dart';
import 'package:educ_student/core/extensions.dart';
import 'package:material_ui/material_ui.dart';

class CollectionExpansionTile extends StatelessWidget {
  final Collection collection;
  final bool isSelected;
  final bool enabled;
  final void Function()? onTap;

  const CollectionExpansionTile({
    super.key,
    required this.collection,
    this.isSelected = false,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          // minTileHeight: 86,
          enabled: enabled,
          onTap: onTap,
          selected: isSelected,
          minVerticalPadding: 24,
          tileColor: context.colorScheme.surfaceContainerLowest,
          selectedTileColor: context.colorScheme.surfaceContainerLowest,
          shape: SmoothRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(
              width: isSelected ? 3 : 0,
              strokeAlign: isSelected ? 3 : 0,
              color: isSelected ? BrandColors.primary1 : Colors.transparent,
            ),
          ),
          leading: SizedBox(
            width: 40,
            height: 40,
            child: SvgPicture.asset(
              Svgs.cloudMoonBlue,
              width: 40,
              height: 40,
            ),
          ),
          title: Text(
            collection.name,
            style: Omnes.w700.getStyle(
              color: !enabled ? context.colorScheme.onSurface.withValues(alpha: 0.5) : context.colorScheme.onSurface,
              fontSize: 16.0,
            ),
            // maxLines: 1,
            softWrap: true,
            // overflow: TextOverflow.ellipsis,
          ),
          trailing: _buildProgressIndicator(context),
          // subtitle: Text(
          //   formatMinutes(collection.readingTime.toDouble()),
          //   maxLines: 1,
          //   overflow: TextOverflow.ellipsis,
          // ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    return SizedBox.square(
      dimension: 16,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 800),
        tween: Tween(
          begin: 0.0,
          end: collection.fulfillmentRatio,
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
    );
  }
}
