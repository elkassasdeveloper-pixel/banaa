import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_student/core/routes.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("not_found".tr()),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "route_not_found".tr(),
              style: Omnes.w700.getStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            IconButton.outlined(
              onPressed: () {
                context.replaceNamed(Routes.ROOT);
              },
              icon: const Icon(Icons.home_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
