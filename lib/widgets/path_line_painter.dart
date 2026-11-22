import 'dart:math';

import 'package:educ_student/core/extensions.dart';
import 'package:material_ui/material_ui.dart';

class PathLinePainter extends CustomPainter {
  final GlobalKey itemKey;
  final GlobalKey? endItemKey;
  final int previousIndex;
  final ScrollController scrollController;
  final Offset globalStartOffset;
  final Color color;

  PathLinePainter({
    super.repaint,
    required this.itemKey,
    required this.endItemKey,
    required this.previousIndex,
    required this.scrollController,
    required this.color,
    required this.globalStartOffset,
  });

  Rect? get startRect => itemKey.getBounds(Offset(
      globalStartOffset.dx, scrollController.offset - globalStartOffset.dy));

  Rect? get endRect => endItemKey?.getBounds(Offset(
      globalStartOffset.dx, scrollController.offset - globalStartOffset.dy));

  @override
  void paint(Canvas canvas, Size size) {
    final startRect = this.startRect;
    final endRect = this.endRect;

    if (startRect == null || endRect == null) {
      return;
    }

    if (startRect.isEmpty || endRect.isEmpty || (startRect.left == 0 && startRect.top == 0) || (endRect.left == 0 && endRect.top == 0)) {
      return;
    }

    final startOffset =
        startRect.topCenter - Offset(0, size.height * (previousIndex + 1));
    final endOffset =
        endRect.bottomCenter - Offset(0, size.height * (previousIndex + 1));

    const margin = 0.0;
    final isSameX = startOffset.dx == endOffset.dx;
    final endIsBeforeStart = startOffset.dx >= endOffset.dx;
    final spaceBetween = startOffset.dy - endOffset.dy - (margin * 2);
    final topMargin = isSameX ? 4.0 : 18.0;
    final cornerRadius = min(
        12.0,
        endIsBeforeStart
            ? (startOffset.dx - endOffset.dx)
            : (endOffset.dx - startOffset.dx));

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    final Path path = Path();

    path.moveTo(startOffset.dx, startOffset.dy - margin);
    path.relativeLineTo(0, (-spaceBetween / 2) + cornerRadius);
    if (endIsBeforeStart) {
      path.relativeArcToPoint(
        Offset(-cornerRadius, -cornerRadius),
        radius: Radius.circular(cornerRadius),
        clockwise: false,
      );
    } else {
      path.relativeArcToPoint(
        Offset(cornerRadius, -cornerRadius),
        radius: Radius.circular(cornerRadius),
        clockwise: true,
      );
    }

    path.relativeLineTo(
        endOffset.dx -
            startOffset.dx +
            cornerRadius * (endIsBeforeStart ? 2 : -2),
        0);
    if (!endIsBeforeStart) {
      path.relativeArcToPoint(
        Offset(cornerRadius, -cornerRadius),
        radius: Radius.circular(cornerRadius),
        clockwise: false,
      );
    } else {
      path.relativeArcToPoint(
        Offset(-cornerRadius, -cornerRadius),
        radius: Radius.circular(cornerRadius),
        clockwise: true,
      );
    }
    path.relativeLineTo(0, -spaceBetween / 2 + topMargin);

    canvas.drawDashedLine(
      path: path,
      paint: paint,
      dashLength: 12,
      dashSpace: 8,
    );
  }

  @override
  bool shouldRepaint(PathLinePainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(PathLinePainter oldDelegate) => true;
}
