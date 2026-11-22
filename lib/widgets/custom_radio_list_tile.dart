import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
import 'package:educ_student/core/extensions.dart';
import 'package:material_ui/material_ui.dart';

class CustomRadioListTile<T> extends StatelessWidget {
  final T? value;
  final T? groupValue;
  final Widget title;
  final ValueChanged<T?> onChanged;
  final Widget? leading;
  final bool enabled;

  const CustomRadioListTile({
    super.key,
    required this.value,
    required this.groupValue,
    required this.title,
    required this.onChanged,
    this.leading,
    this.enabled = true,
  });

  bool get isSelected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    final leading = this.leading;

    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: SizedBox(
        height: 56,
        child: Material(
          type: MaterialType.button,
          clipBehavior: Clip.antiAlias,
          color: _getBackgroundColor(context),
          shape: SmoothRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: _getBorderSide(context),
          ),
          child: InkWell(
            onTap: enabled ? () => onChanged.call(value) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ?leading,
                  const SizedBox(width: 12),
                  _title(context),
                  const Spacer(),
                  _customRadioButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BorderSide _getBorderSide(BuildContext context) {
    return isSelected
        ? BorderSide(width: 2, color: context.colorScheme.primaryContainer)
        : BorderSide(width: 0, color: context.colors.outline);
  }

  Widget _customRadioButton(BuildContext context) {
    if (!isSelected) return const SizedBox.shrink();
    return Icon(
      Icons.check_rounded,
      color: context.colorScheme.primaryContainer,
    );
  }

  Widget _title(BuildContext context) {
    return DefaultTextStyle.merge(
      style: TextStyle(
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        fontSize: 16,
        color: context.colorScheme.onSurface.withValues(
          alpha: enabled ? 1.0 : 0.6,
        ),
      ),
      child: title,
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    return isSelected
        ? context.colors.shapeContainer
        : context.colorScheme.surfaceContainerLow.withValues(alpha: 0.5);
  }
}
