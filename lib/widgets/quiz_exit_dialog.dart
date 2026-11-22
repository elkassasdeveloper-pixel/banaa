import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/helpers.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

class QuizExitDialog extends StatelessWidget {
  const QuizExitDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.colorScheme.surfaceContainerLow,
      shape: SmoothRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      content: Text(
        "are_you_sure_you_want_to_exit".tr(),
        style: Omnes.w700.getStyle(
          fontSize: 20,
          color: context.colorScheme.primary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Navigator.pop(context);
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(
            foregroundColor: context.colorScheme.primary,
          ),
          child: Text(
            "no".tr(),
            style: Omnes.w500.getStyle(fontSize: 16),
          ),
        ),
        FilledButton(
          onPressed: () {
            context.pop();
            context.pop();
            doPostFrame((_) {
              Navigator.pop(context);
            });
          },
          style: FilledButton.styleFrom(
            foregroundColor: context.colorScheme.onError,
            backgroundColor: context.colorScheme.error,
          ),
          child: Text(
            "yes".tr(),
            style: Omnes.w500.getStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
