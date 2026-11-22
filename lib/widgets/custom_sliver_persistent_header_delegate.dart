import 'package:educ_core/utils/extensions.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';

/// [Factor]: The extrapolation factor (0.0 -> 1.0)
typedef ExtrapolationFactor = double Function(double factor);

/// [t]: The extrapolation factor function
///
/// [s]: The current shrink offset (shrinkOffset)
///
/// [o]: Indicates if the header overlaps the content (overlapsContent)
///
typedef ExtrapolationFactorCallback<T> = T Function(
    ExtrapolationFactor t, double s, bool o);

class CustomSliverPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  const CustomSliverPersistentHeaderDelegate({
    required this.topPanel,
    required this.bottomPanel,
    this.decoration,
    double? minExtent,
    double? maxExtent,
    this.paddingExpanded,
    this.paddingCollapsed,
    this.bottomPanelOpacityFactor = 0.2,
  })  : minExtent = minExtent ?? _defaultMinExtent,
        maxExtent = maxExtent ?? _defaultMaxExtent,
        vsync = null,
        snapConfiguration = null;

  const CustomSliverPersistentHeaderDelegate.snap({
    required this.vsync,
    required this.snapConfiguration,
    required this.topPanel,
    required this.bottomPanel,
    this.decoration,
    double? minExtent,
    double? maxExtent,
    this.paddingExpanded,
    this.paddingCollapsed,
    this.bottomPanelOpacityFactor = 0.2,
  })  : minExtent = minExtent ?? _defaultMinExtent,
        maxExtent = maxExtent ?? _defaultMaxExtent;

  final ExtrapolationFactorCallback<Widget> topPanel;
  final ExtrapolationFactorCallback<Widget> bottomPanel;
  final ExtrapolationFactorCallback<Decoration>? decoration;
  final EdgeInsetsGeometry? paddingExpanded;
  final EdgeInsetsGeometry? paddingCollapsed;
  final double bottomPanelOpacityFactor;

  @override
  final double minExtent;
  @override
  final double maxExtent;
  @override
  final TickerProvider? vsync;
  @override
  final FloatingHeaderSnapConfiguration? snapConfiguration;

  static const _defaultMinExtent = 80.0;
  static const _defaultMaxExtent = 250.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // const overlayColor = Color.fromRGBO(0, 0, 0, 0.15);

    return Center(
      child: Container(
        clipBehavior: Clip.none,
        padding: EdgeInsetsGeometry.lerp(
          paddingExpanded,
          paddingCollapsed,
          _t(shrinkOffset, 0.5),
        ),
        decoration: decoration?.call(
              (t) => _t(shrinkOffset, t),
              shrinkOffset,
              overlapsContent,
            ) ??
            BoxDecoration(color: context.colorScheme.surfaceContainer),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ~ ⏫ top panel ~ //
            Align(
              alignment: Alignment.topCenter,
              child: topPanel(
                (time) => _t(shrinkOffset, time),
                shrinkOffset,
                overlapsContent,
              ),
            ),

            //~ ⏬  bottom panel ~ //
            Align(
              alignment: Alignment.bottomCenter,
              child: Opacity(
                opacity: 1 - _t(shrinkOffset, bottomPanelOpacityFactor),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: bottomPanel(
                    (time) => _t(shrinkOffset, time),
                    shrinkOffset,
                    overlapsContent,
                  ),
                ),
              ),
            ),
          ].reversed.toList(),
        ),
      ),
    );
  }

  double _t(double shrinkOffset, double time) {
    final x = (shrinkOffset / (minExtent * time));
    return x.clamp(0.0, 1.0);
  }

  @override
  bool shouldRebuild(
          covariant CustomSliverPersistentHeaderDelegate oldDelegate) =>
      oldDelegate.minExtent != minExtent ||
      oldDelegate.maxExtent != maxExtent ||
      oldDelegate.topPanel != topPanel ||
      oldDelegate.bottomPanel != bottomPanel ||
      oldDelegate.decoration != decoration ||
      oldDelegate.paddingExpanded != paddingExpanded ||
      oldDelegate.paddingCollapsed != paddingCollapsed ||
      oldDelegate.bottomPanelOpacityFactor != bottomPanelOpacityFactor;
}
