import 'package:educ_student/core/extensions.dart';
import 'package:material_ui/material_ui.dart';

class GradiantScreen extends StatelessWidget {
  final Widget child;

  const GradiantScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.linearBackground.start,
            context.colors.linearBackground.end,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}
