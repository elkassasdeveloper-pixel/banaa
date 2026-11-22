import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_student/core/assets.dart';
import 'package:educ_student/core/extensions.dart';
import 'package:material_ui/material_ui.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final Widget Function(T item) itemBuilder;
  final Widget? prefixIcon;
  final bool isExpanded;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.itemBuilder,
    this.isExpanded = true,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      isExpanded: isExpanded,
      icon: SvgPicture.asset(
        Svgs.arrowDown,
        colorFilter: context.colors.headline.toColorFilter(),
      ),
      iconSize: 12,
      initialValue: value,
      items: items.map(
        (item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 8.0),
              child: itemBuilder(item),
            ),
          );
        },
      ).toList(),
      isDense: true,
      onChanged: onChanged,
      borderRadius: BorderRadius.circular(8),
      decoration: InputDecoration(
        filled: true,
        fillColor: context.colors.headline.withValues(alpha: 0.12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        constraints: const BoxConstraints(maxHeight: 34),
        prefixIcon: prefixIcon,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 32,
          maxHeight: 20,
        ),
      ),
      style: Omnes.w700.getStyle(
        fontSize: 14,
        color: context.colors.headline,
      ),
    );
  }
}
