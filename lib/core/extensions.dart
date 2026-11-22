import 'package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart';
import 'package:educ_core/data/models/user.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_student/core/colors_theme_ext.dart';
import 'package:educ_student/screens/auth/auth_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;

extension BuildContextExt on BuildContext {
  User? get user {
    final state = read<AuthCubit>().state;
    if (state is Authenticated) {
      return state.user;
    } else {
      return null;
    }
  }

  ColorsThemeExt get colors => theme.extension<ColorsThemeExt>()!;

  bool get isDark => theme.brightness == Brightness.dark;

  bool get isStandard => Breakpoints.standard.isActive(this);

  bool get isSmall => Breakpoints.small.isActive(this);

  bool get isSmallAndUp => Breakpoints.smallAndUp.isActive(this);

  bool get isSmallDesktop => Breakpoints.smallDesktop.isActive(this);

  bool get isSmallMobile => Breakpoints.smallMobile.isActive(this);

  bool get isMedium => Breakpoints.medium.isActive(this);

  bool get isMediumAndUp => Breakpoints.mediumAndUp.isActive(this);

  bool get isMediumDesktop => Breakpoints.mediumDesktop.isActive(this);

  bool get isMediumMobile => Breakpoints.mediumMobile.isActive(this);

  bool get isLarge => Breakpoints.large.isActive(this);

  bool get isLargeDesktop => Breakpoints.largeDesktop.isActive(this);

  bool get isLargeMobile => Breakpoints.largeMobile.isActive(this);
}

extension StringExt on String {
  TextDirection getTextDirection() => intl.Bidi.detectRtlDirectionality(this) ? TextDirection.rtl : TextDirection.ltr;
}

extension CanvasExt on Canvas {
  void drawDashedLine({
    required Path path,
    required Paint paint,
    required double dashLength,
    required double dashSpace,
  }) {
    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      for (double dist = 0; dist < pathMetric.length; dist += dashLength + dashSpace) {
        final dashPath = pathMetric.extractPath(dist, dist + dashLength);

        drawPath(dashPath, paint);
      }
    }
  }
}

extension GlobalKeyExt on GlobalKey {
  Rect? getBounds([Offset? point]) {
    final renderObject = currentContext?.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      return renderObject.localToGlobal(point ?? Offset.zero) & renderObject.size;
    } else {
      return null;
    }
  }
}
