import 'package:material_ui/material_ui.dart';

class OnBoardingShapePainter extends CustomPainter {
  final Color color;

  const OnBoardingShapePainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..relativeQuadraticBezierTo(size.width * 0.5, -80, size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  @override
  bool? hitTest(Offset position) => false;
}
