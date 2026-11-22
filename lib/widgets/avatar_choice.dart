import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
import 'package:educ_student/core/brand_colors.dart';
import 'package:material_ui/material_ui.dart';

class AvatarChoice extends StatelessWidget {
  final String url;
  final VoidCallback? onSelected;
  final bool isSelected;
  final double borderWidth;

  const AvatarChoice({
    super.key,
    required this.url,
    this.onSelected,
    this.isSelected = false,
    this.borderWidth = 1,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        type: MaterialType.transparency,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl:Uri.encodeFull(url),
              memCacheWidth: 300,
              imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
              imageBuilder: (context, imageProvider) {
                return _buildFrame(
                  context,
                  borderSide: BorderSide(
                    color: isSelected
                        ? BrandColors.primary1
                        : context.colorScheme.tertiary.withValues(alpha: 0.3),
                    width: isSelected ? 2 : borderWidth,
                  ),
                  image: DecorationImage(
                    image: imageProvider,
                    opacity: isSelected ? 1 : 0.7,
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter,
                  ),
                );
              },
              progressIndicatorBuilder: (context, url, downloadProgress) {
                return _buildFrame(
                  context,
                  borderSide: BorderSide(
                    color: context.colorScheme.outline,
                    width: 1,
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      value: downloadProgress.progress,
                    ),
                  ),
                );
              },
              errorWidget: (context, url, error) {
                debugPrint('AvatarChoice failed: $url -> $error');
                return _buildFrame(
                  context,
                  borderSide: BorderSide(
                    color: context.colorScheme.error,
                    width: isSelected ? 3 : 1,
                  ),
                  child: Icon(
                    Icons.image_not_supported_rounded,
                    color: context.colorScheme.error,
                  ),
                );
              },
            ),
            InkWell(
              onTap: onSelected,
              customBorder: SmoothRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFrame(
    BuildContext context, {
    BorderSide borderSide = BorderSide.none,
    Widget? child,
    DecorationImage? image,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: ShapeDecoration(
        color: context.colorScheme.tertiaryContainer
            .alphaBlend(context.colorScheme.surface, 0.15),
        shape: SmoothRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: borderSide,
        ),
        image: image,
      ),
      child: child,
    );
  }
}
