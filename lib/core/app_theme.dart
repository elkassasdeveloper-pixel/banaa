import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_input_border.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
import 'package:educ_student/core/brand_colors.dart';
import 'package:educ_student/core/colors_theme_ext.dart';
import 'package:material_ui/material_ui.dart';


abstract class AppTheme {
  ColorScheme get colorScheme;

  ColorsThemeExt get colors;

  ThemeData get themeData => FlexColorScheme(
    fontFamilyFallback: const ['sans-serif'],
        brightness: colorScheme.brightness,
        useMaterial3: true,
        fontFamily: Omnes.fontFamily,
        colorScheme: colorScheme,
        extensions: [
          colors,
        ],
        visualDensity: VisualDensity.comfortable,
        transparentStatusBar: true,
      ).toTheme.copyWith(
            scaffoldBackgroundColor: colors.background,
            appBarTheme: AppBarTheme(
              backgroundColor: colors.background,
              // elevation: 0,
              // scrolledUnderElevation: 3,
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                shape: const SmoothRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                minimumSize: const Size.square(48),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                shape: const SmoothRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                minimumSize: const Size.square(48),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                shape: const SmoothRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                minimumSize: const Size.square(48),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                shape: const SmoothRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                minimumSize: const Size.square(48),
                textStyle: Omnes.w600.getStyle(fontSize: 16),
              ),
            ),
            iconButtonTheme: IconButtonThemeData(
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(12),
                shape: const SmoothRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                minimumSize: const Size.square(48),
              ),
            ),
            scrollbarTheme: _scrollBarTheme(),
            inputDecorationTheme: InputDecorationTheme(
              floatingLabelBehavior: FloatingLabelBehavior.never,
              border: SmoothInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: colorScheme.primary, width: 1),
              ),
              enabledBorder: SmoothInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: colorScheme.outline, width: 1),
              ),
              errorBorder: SmoothInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: colorScheme.error, width: 1),
              ),
              focusedErrorBorder: SmoothInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: colorScheme.error, width: 2),
              ),
              focusedBorder: SmoothInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              disabledBorder: SmoothInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: colorScheme.outline, width: 1),
              ),
            ),
            navigationRailTheme: NavigationRailThemeData(
              minExtendedWidth: 240.0,
              backgroundColor: Colors.transparent,
              indicatorColor: colorScheme.primary.alphaBlend(
                colors.bottomNavBarBackground,
                0.2,
              ),
              selectedIconTheme: const IconThemeData(
                color: BrandColors.primary1,
              ),
              unselectedIconTheme: IconThemeData(
                color: colorScheme.primary.withValues(alpha: 0.6),
              ),
              selectedLabelTextStyle: Omnes.w700.getStyle(color: BrandColors.primary1),
              unselectedLabelTextStyle: Omnes.w500.getStyle(color: colorScheme.primary.withValues(alpha: 0.4)),
            ),
            navigationBarTheme: NavigationBarThemeData(
              surfaceTintColor: colorScheme.primary,
              backgroundColor: Colors.transparent,
              indicatorColor: colorScheme.primary.alphaBlend(
                colors.bottomNavBarBackground,
                0.2,
              ),
              labelTextStyle: WidgetStateProperty.resolveWith(
                (states) {
                  if (states.contains(WidgetState.selected)) {
                    return Omnes.w700.getStyle(color: BrandColors.primary1, fontSize: 8);
                  }
                  return Omnes.w500.getStyle(color: colorScheme.primary.withValues(alpha: 0.4), fontSize: 7);
                },
              ),
            ),
            bottomSheetTheme: BottomSheetThemeData(
              backgroundColor: colorScheme.surfaceContainerLow,
              shape: const SmoothRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(32.0)),
              ),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: colorScheme.surfaceContainerLowest,
              selectedItemColor: colorScheme.primary,
              unselectedItemColor: colorScheme.outline,
            ),
            dropdownMenuTheme: DropdownMenuThemeData(
              menuStyle: const MenuStyle(
                  shape: WidgetStatePropertyAll(
                    SmoothRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                  ),
                  padding: WidgetStatePropertyAll(EdgeInsets.zero)),
              inputDecorationTheme: InputDecorationTheme(
                border: const SmoothInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                enabledBorder: SmoothInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  borderSide: BorderSide(color: colorScheme.outline, width: 1),
                ),
              ),
              textStyle: Omnes.w600.getStyle(fontSize: 16),
            ),
          );

  ScrollbarThemeData _scrollBarTheme() {
    return ScrollbarThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        final bool isVisible = states.any((e) {
          switch (e) {
            case WidgetState.dragged:
            case WidgetState.hovered:
              return true;
            default:
              return false;
          }
        });

        if (isVisible) {
          return colorScheme.tertiary;
        } else {
          return colorScheme.tertiary.withValues(alpha: 0.5);
        }
      }),
      trackVisibility: const WidgetStatePropertyAll(true),
      trackColor: WidgetStatePropertyAll(colorScheme.tertiary.withValues(alpha: 0.1)),
    );
  }
}
