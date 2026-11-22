import 'package:material_ui/material_ui.dart';

typedef LinearBackground = ({Color start, Color end});

class ColorsThemeExt extends ThemeExtension<ColorsThemeExt> {
  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color background;
  final Color headline;
  final Color subHeadline;
  final Color bodyText;
  final Color iconContainer;
  final Color shapeContainer;
  final Color container;
  final Color bgShadow;
  final Color outline;
  final LinearBackground linearBackground;
  final LinearBackground linearLearnCardBackground;
  final Color appBarBackground;
  final Color appBarBorder;
  final Color appBarShadow;
  final Color bottomNavBarBackground;

  const ColorsThemeExt({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.background,
    required this.headline,
    required this.subHeadline,
    required this.bodyText,
    required this.iconContainer,
    required this.shapeContainer,
    required this.container,
    required this.bgShadow,
    required this.outline,
    required this.linearBackground,
    required this.linearLearnCardBackground,
    required this.appBarBackground,
    required this.appBarBorder,
    required this.appBarShadow,
    required this.bottomNavBarBackground,
  });

  LinearGradient get linearBackgroundGradient => LinearGradient(
        colors: [linearBackground.start, linearBackground.end],
        stops: const [0.0, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  LinearGradient get linearLearnCardBackgroundGradient => LinearGradient(
        colors: [
          linearLearnCardBackground.start,
          linearLearnCardBackground.end
        ],
        begin: const Alignment(1.00, 0.00),
        end: const Alignment(-1, 0),
      );

  @override
  ColorsThemeExt copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? background,
    Color? headline,
    Color? subHeadline,
    Color? bodyText,
    Color? iconContainer,
    Color? shapeContainer,
    Color? container,
    Color? bgShadow,
    Color? outline,
    LinearBackground? linearBackground,
    LinearBackground? linearLearnCardBackground,
    Color? appBarBackground,
    Color? appBarBorder,
    Color? appBarShadow,
    Color? bottomNavBarBackground,
  }) {
    return ColorsThemeExt(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      background: background ?? this.background,
      headline: headline ?? this.headline,
      subHeadline: subHeadline ?? this.subHeadline,
      bodyText: bodyText ?? this.bodyText,
      iconContainer: iconContainer ?? this.iconContainer,
      shapeContainer: shapeContainer ?? this.shapeContainer,
      container: container ?? this.container,
      bgShadow: bgShadow ?? this.bgShadow,
      outline: outline ?? this.outline,
      linearBackground: linearBackground ?? this.linearBackground,
      linearLearnCardBackground:
          linearLearnCardBackground ?? this.linearLearnCardBackground,
      appBarBackground: appBarBackground ?? this.appBarBackground,
      appBarBorder: appBarBorder ?? this.appBarBorder,
      appBarShadow: appBarShadow ?? this.appBarShadow,
      bottomNavBarBackground:
          bottomNavBarBackground ?? this.bottomNavBarBackground,
    );
  }

  @override
  ColorsThemeExt lerp(covariant ColorsThemeExt? other, double t) {
    if (other is! ColorsThemeExt) {
      return this;
    }

    return ColorsThemeExt(
      success: Color.lerp(success, other.success, t) ?? success,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t) ?? onSuccess,
      successContainer:
          Color.lerp(successContainer, other.successContainer, t) ??
              successContainer,
      onSuccessContainer:
          Color.lerp(onSuccessContainer, other.onSuccessContainer, t) ??
              onSuccessContainer,
      background: Color.lerp(background, other.background, t) ?? background,
      headline: Color.lerp(headline, other.headline, t) ?? headline,
      subHeadline: Color.lerp(subHeadline, other.subHeadline, t) ?? subHeadline,
      bodyText: Color.lerp(bodyText, other.bodyText, t) ?? bodyText,
      iconContainer:
          Color.lerp(iconContainer, other.iconContainer, t) ?? iconContainer,
      shapeContainer:
          Color.lerp(shapeContainer, other.shapeContainer, t) ?? shapeContainer,
      container: Color.lerp(container, other.container, t) ?? container,
      bgShadow: Color.lerp(bgShadow, other.bgShadow, t) ?? bgShadow,
      outline: Color.lerp(outline, other.outline, t) ?? outline,
      linearBackground: (
        start: Color.lerp(
                linearBackground.start, other.linearBackground.start, t) ??
            linearBackground.start,
        end: Color.lerp(linearBackground.end, other.linearBackground.end, t) ??
            linearBackground.end,
      ),
      linearLearnCardBackground: (
        start: Color.lerp(linearLearnCardBackground.start,
                other.linearLearnCardBackground.start, t) ??
            linearLearnCardBackground.start,
        end: Color.lerp(linearLearnCardBackground.end,
                other.linearLearnCardBackground.end, t) ??
            linearLearnCardBackground.end,
      ),
      appBarBackground:
          Color.lerp(appBarBackground, other.appBarBackground, t) ??
              appBarBackground,
      appBarBorder:
          Color.lerp(appBarBorder, other.appBarBorder, t) ?? appBarBorder,
      appBarShadow:
          Color.lerp(appBarShadow, other.appBarShadow, t) ?? appBarShadow,
      bottomNavBarBackground:
          Color.lerp(bottomNavBarBackground, other.bottomNavBarBackground, t) ??
              bottomNavBarBackground,
    );
  }
}
