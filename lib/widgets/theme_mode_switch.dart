import 'package:educ_student/core/brand_colors.dart';
import 'package:material_ui/material_ui.dart';

class ThemeModeSwitch extends StatelessWidget {
  const ThemeModeSwitch({
    super.key,
    required this.isDark,
    required this.onChanged,
  })  : _isTile = false,
        title = null;

  const ThemeModeSwitch.tile({
    super.key,
    required Widget this.title,
    required this.isDark,
    required this.onChanged,
  }) : _isTile = true;

  final bool isDark;
  final ValueChanged<bool> onChanged;
  final bool _isTile;
  final Widget? title;

  @override
  Widget build(BuildContext context) {
    final switchWidget = Switch(
      value: isDark,
      onChanged: onChanged,
      activeThumbColor: BrandColors.white,
      activeTrackColor: BrandColors.primary2,
      inactiveTrackColor: Colors.transparent,
      inactiveThumbColor: BrandColors.primary1,
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) {
          if (!states.contains(WidgetState.selected)) {
            return BrandColors.primary1;
          }
          return null;
        },
      ),
      thumbIcon: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return const Icon(
              Icons.brightness_4,
              color: BrandColors.primary2,
            );
          }
          return const Icon(
            Icons.brightness_7,
            color: Colors.white,
          );
        },
      ),
    );

    if (_isTile) {
      return ListTile(
        onTap: () => onChanged(!isDark),
        title: title,
        trailing: switchWidget,
      );
    }
    return switchWidget;
  }
}
