import 'package:educ_core/utils/extensions.dart';
import 'package:material_ui/material_ui.dart';

class PageIndicator extends StatelessWidget {
  final int currentIndex;
  final int pagesCount;

  const PageIndicator({super.key, required this.currentIndex, required this.pagesCount});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 20,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (int i = 0; i < pagesCount; i++)
            Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: currentIndex == i
                          ? context.colorScheme.inverseSurface
                          : context.colorScheme.inverseSurface.withValues(alpha: 0.3)),
                ))
        ]));
  }
}
