import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_student/core/assets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

class BackArrowButton extends StatelessWidget {
  const BackArrowButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: context.pop,
      icon: SvgPicture.asset(
        Svgs.backArrow,
        colorFilter: context.colorScheme.primary.toColorFilter(),
        matchTextDirection: true,
      ),
    );
  }
}
