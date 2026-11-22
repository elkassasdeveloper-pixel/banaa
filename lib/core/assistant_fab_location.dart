import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';

class AssistantFabLocation extends StandardFabLocation {
  @override
  double getOffsetX(
      ScaffoldPrelayoutGeometry scaffoldGeometry, double adjustment) {
    return scaffoldGeometry.scaffoldSize.width -
        scaffoldGeometry.floatingActionButtonSize.width -
        adjustment;
  }

  @override
  double getOffsetY(
      ScaffoldPrelayoutGeometry scaffoldGeometry, double adjustment) {
    final double contentBottom = scaffoldGeometry.contentBottom;
    final double bottomContentHeight =
        scaffoldGeometry.scaffoldSize.height - contentBottom;
    final double bottomSheetHeight = scaffoldGeometry.bottomSheetSize.height;
    final double fabHeight = scaffoldGeometry.floatingActionButtonSize.height;
    final double snackBarHeight = scaffoldGeometry.snackBarSize.height;
    final double safeMargin = math.max(
        0.0, scaffoldGeometry.minViewPadding.bottom - bottomContentHeight);

    double fabY = contentBottom - fabHeight - safeMargin;
    if (snackBarHeight > 0.0) {
      fabY = math.min(
          fabY,
          contentBottom -
              snackBarHeight -
              fabHeight -
              kFloatingActionButtonMargin);
    }
    if (bottomSheetHeight > 0.0) {
      fabY =
          math.min(fabY, contentBottom - bottomSheetHeight - fabHeight / 2.0);
    }
    return fabY + adjustment;
  }
}

class NoAnimationFabMotionAnimator extends FloatingActionButtonAnimator {
  const NoAnimationFabMotionAnimator();

  @override
  Offset getOffset(
      {required Offset begin, required Offset end, required double progress}) {
    return end;
  }

  @override
  Animation<double> getRotationAnimation({required Animation<double> parent}) {
    return const AlwaysStoppedAnimation<double>(1.0);
  }

  @override
  Animation<double> getScaleAnimation({required Animation<double> parent}) {
    return const AlwaysStoppedAnimation<double>(1.0);
  }

  @override
  double getAnimationRestart(double previousValue) => 1.0;
}
