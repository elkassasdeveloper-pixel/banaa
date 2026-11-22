import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
import 'package:educ_student/core/extensions.dart';
import 'package:material_ui/material_ui.dart';

class RootCollectionDropdownButton extends StatelessWidget {
  final String? label;
  final VoidCallback? onPressed;

  const RootCollectionDropdownButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Material(
        type: MaterialType.button,
        color: context.colors.iconContainer.withValues(alpha: 0.1),
        shape: SmoothRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 32,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  label != null
                      ? Flexible(
                          child: Text(
                            label!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Omnes.w700.getStyle(
                              fontSize: 16,
                              color: context.colors.headline,
                            ),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.all(4),
                          alignment: AlignmentDirectional.centerStart,
                          child: const AspectRatio(
                            aspectRatio: 1,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: context.colors.headline,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
