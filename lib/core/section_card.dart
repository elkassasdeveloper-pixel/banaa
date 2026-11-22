import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:material_ui/material_ui.dart';

class SectionCard extends StatelessWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  const SectionCard({this.color, super.key, this.title, this.actions, this.padding, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      // color: context.colorScheme.surface,
      color: color ?? context.colorScheme.surfaceContainerLowest,
      elevation: 2,
      shadowColor: context.colorScheme.shadow.withValues(alpha: 0.3),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (title != null)
                  Flexible(
                    flex: 1,
                    child: Text(
                      title!,
                      style: ElMessiri.w600.getStyle( fontSize: 22, color: context.colorScheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(width: 16),
                if (actions != null) OverflowBar(alignment: MainAxisAlignment.end, children: actions!),
              ],
            ),
            if (title != null || actions != null) const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
