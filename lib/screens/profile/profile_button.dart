import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
import 'package:educ_student/core/assets.dart';
import 'package:material_ui/material_ui.dart';

class ProfileButton extends StatelessWidget {
  final void Function()? onTap;
  final String title;
  final String iconPath;

  const ProfileButton({
    super.key,
    required this.onTap,
    required this.title,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: SvgPicture.asset(
        iconPath,
        colorFilter: context.colorScheme.primary.toColorFilter(),
        height: 24,
        width: 24,
      ),
      title: Text(
        title,
        style: Omnes.w700.getStyle(
          fontSize: 16,
          color: context.colorScheme.primary,
        ),
      ),
      trailing: SvgPicture.asset(
        Svgs.forwardArrow,
        colorFilter: context.colorScheme.primary.toColorFilter(),
        matchTextDirection: true,
        height: 24,
        width: 24,
      ),
      // tileColor: context.colorScheme.surface,
      shape: SmoothRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: context.colorScheme.primary,
          width: 1,
        ),
      ),
    );
  }
}
