import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/services/cache_helper.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_student/core/assets.dart';
import 'package:educ_student/core/brand_colors.dart';
import 'package:educ_student/core/constants.dart';
import 'package:educ_student/core/extensions.dart';
import 'package:educ_student/core/routes.dart';
import 'package:educ_student/screens/on_boarding/on_boarding_cubit.dart';
import 'package:educ_student/screens/on_boarding/on_boarding_item.dart';
import 'package:educ_student/screens/other/settings_cubit.dart';
import 'package:educ_student/widgets/on_boarding_shape_painter.dart';
import 'package:educ_student/widgets/theme_mode_switch.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

const double _circlePatternSize = 340;
const double _bottomShapeMinHeight = 380;

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  static final List<OnboardingItem> onboardingItems = [
    OnboardingItem(
      title: "on_boarding.title_0",
      description: "on_boarding.description_0",
      image: Images.onBoarding0,
    ),
    OnboardingItem(
      title: "on_boarding.title_1",
      description: "on_boarding.description_1",
      image: Images.onBoarding1,
    ),
    OnboardingItem(
      title: "on_boarding.title_2",
      description: "on_boarding.description_2",
      image: Images.onBoarding2,
    ),
    OnboardingItem(
      title: "on_boarding.title_3",
      description: "on_boarding.description_3",
      image: Images.onBoarding3,
    ),
    OnboardingItem(
      title: "on_boarding.title_4",
      description: "on_boarding.description_4",
      image: Images.onBoarding4,
    )
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnBoardingCubit(
        pagesCount: onboardingItems.length,
      ),
      child: BlocBuilder<OnBoardingCubit, OnBoardingState>(
        builder: (context, state) {
          final cubit = context.read<OnBoardingCubit>();

          return Scaffold(
            body: SafeArea(
              child: LayoutBuilder(builder: (context, constraints) {
                final double circlePatternTop = (constraints.maxHeight -
                        _bottomShapeMinHeight.h -
                        _circlePatternSize.h / 2) -
                    (_circlePatternSize.h / 2);
                return Stack(
                  clipBehavior: Clip.none,
                  fit: StackFit.loose,
                  alignment: Alignment.topCenter,
                  children: [
                    NotificationListener(
                      onNotification: (notification) {
                        if (notification is ScrollUpdateNotification) {
                          cubit.onScroll(
                            notification.metrics.pixels,
                            notification.metrics.maxScrollExtent,
                            onboardingItems.length,
                          );
                        }
                        return true;
                      },
                      child: PageView.builder(
                        itemCount: onboardingItems.length,
                        controller: cubit.pageController,
                        onPageChanged: cubit.onPageChanged,
                        itemBuilder: (context, index) {
                          return const SizedBox.expand();
                        },
                      ),
                    ),
                    Positioned(
                      top: circlePatternTop,
                      child: SizedBox(
                        width: _circlePatternSize.h,
                        height: _circlePatternSize.h,
                        child: IgnorePointer(
                          child: SvgPicture.asset(
                            Svgs.circlePattern,
                            colorFilter: BrandColors.primary3
                                .withValues(alpha: context.isDark ? 0.12 : 0.6)
                                .toColorFilter(),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: circlePatternTop,
                      child: IgnorePointer(
                        child: Transform.rotate(
                          alignment: Alignment.center,
                          angle: context.textDirection == TextDirection.ltr
                              ? -state.angle
                              : state.angle,
                          child: _buildImage(context, state.currentIndex),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      // height: context.mediaQuery.size.height * 0.4,
                      child: _buildBottomView(context, state),
                    ),
                    Align(
                      alignment: const Alignment(0, -0.95),
                      child: IgnorePointer(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: state.currentIndex > 0 ? 1 : 0,
                          child: Hero(
                            tag: Strings.logoHeroTag,
                            child: SvgPicture.asset(
                              Svgs.banaaLogoWithText,
                              height: 56,
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildPreferenceActions(context, state),
                  ],
                );
              }),
            ),
          );
        },
      ),
    );
  }

  Row _buildPreferenceActions(BuildContext context, OnBoardingState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
          onPressed: () => goToAuthScreen(context),
          child: Text(
            "skip".tr(),
            style: Omnes.w700
                .getStyle(fontSize: 16, color: context.colors.headline),
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: IgnorePointer(
            ignoring: state.currentIndex != 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: state.currentIndex == 0 ? 1 : 0,
              child: BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, _) {
                  final cubit = context.read<SettingsCubit>();
                  return IntrinsicHeight(
                    child: OverflowBar(
                      // layoutBehavior: ButtonBarLayoutBehavior.constrained,
                      // overflowButtonSpacing: 8.0,
                      alignment: MainAxisAlignment.end,
                      children: [
                        // IntrinsicWidth(
                        //   child: CustomDropdown(
                        //     isExpanded: true,
                        //     value: context.locale,
                        //     items: Consts.supportedLocales,
                        //     itemBuilder: (item) {
                        //       return Text(localeToLanguageName(item).tr());
                        //     },
                        //     onChanged: (value) {
                        //       if (value != null) {
                        //         context.setLocale(value);
                        //       }
                        //     },
                        //   ),
                        // ),
                        ThemeModeSwitch(
                          isDark: cubit.isDarkMode,
                          onChanged: cubit.setDarkMode,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage(BuildContext context, int currentIndex) {
    final index = currentIndex % 2 == 0 ? currentIndex : currentIndex - 1;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: _circlePatternSize.h,
          child: Image.asset(
            onboardingItems[index].image,
          ),
        ),
        SizedBox(height: (context.mediaQuery.size.height * 0.5)),
        SizedBox.square(
          dimension: _circlePatternSize.h,
          child: (currentIndex + 1 < onboardingItems.length)
              ? Transform.rotate(
                  angle: -180 * pi / 180,
                  child: Image.asset(
                    onboardingItems[index + 1].image,
                  ),
                )
              : const SizedBox.shrink(),
        )
      ],
    );
  }

  CustomPaint _buildBottomView(BuildContext context, OnBoardingState state) {
    return CustomPaint(
      painter: OnBoardingShapePainter(
        color: context.isDark
            ? context.colors.shapeContainer
            : BrandColors.primary3,
      ),
      child: Container(
        constraints: BoxConstraints(
          minHeight: _bottomShapeMinHeight.h,
        ),
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
        child: SafeArea(
          bottom: true,
          top: false,
          left: false,
          right: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IgnorePointer(
                child: Column(
                  children: [
                    AutoSizeText(
                      onboardingItems[state.currentIndex].title.tr(
                        namedArgs: {
                          // "app_name": context.locale.languageCode == "ar"
                          //     ? Strings.appNameAr
                          //     : Strings.appNameEn
                          "app_name": "app_name".tr(),
                        },
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: Omnes.w900.getStyle(
                        fontSize: 38,
                        color: context.colors.headline,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AutoSizeText(
                      onboardingItems[state.currentIndex].description.tr(),
                      textAlign: TextAlign.center,
                      style: Omnes.w400.getStyle(
                        // fontSize: 18,
                        color: context.colors.headline,
                      ),maxLines: 3,minFontSize: 18,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              _buildNextButton(
                context,
                isLast: state.currentIndex == onboardingItems.length - 1,
                progress: state.progress,
              ),
              const SizedBox(height: 16),
              IgnorePointer(
                child: Text.rich(
                  TextSpan(
                    text: "${state.currentIndex + 1}",
                    style: Omnes.w700.getStyle(
                      color: context.colors.headline,
                      fontSize: 32,
                    ),
                    children: [
                      TextSpan(
                        text: "/${onboardingItems.length}",
                        style: Omnes.w700.getStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(BuildContext context,
      {bool isLast = false, double progress = 0.0}) {
    return SizedBox.square(
      dimension: 92,
      child: Stack(
        children: [
          Positioned.fill(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(
                context.colors.headline,
              ),
              backgroundColor: context.colors.background,
              strokeCap: StrokeCap.round,
              value: progress,
            ),
          ),
          Center(
            child: IconButton(
              onPressed: () {
                if (isLast) {
                  goToAuthScreen(context);
                } else {
                  context.read<OnBoardingCubit>().onNextPressed();
                }
              },
              icon: SvgPicture.asset(
                Svgs.arrowRight,
                width: 24,
                height: 24,
                colorFilter: context.colors.background.toColorFilter(),
                matchTextDirection: true,
              ),
              style: IconButton.styleFrom(
                foregroundColor: context.colors.background,
                backgroundColor: context.colors.headline,
                fixedSize: const Size.square(68),
                shape: const CircleBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void goToAuthScreen(BuildContext context) {
    context.pushNamed(Routes.AUTH);
    CacheHelper.setIsFirstRun(false);
  }
}
