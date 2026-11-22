import 'package:material_ui/material_ui.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.child,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final BoxConstraints constraints;

    if (size.width >= 800) {
      constraints = const BoxConstraints(maxWidth: 800);
    } else if (size.width >= 600) {
      constraints = const BoxConstraints(maxWidth: 600);
    } else {
      return child;
    }

    return Align(
      alignment: alignment ?? AlignmentDirectional.topStart,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.fastLinearToSlowEaseIn,
        constraints: constraints,
        child: child,
      ),
    );
  }
}
