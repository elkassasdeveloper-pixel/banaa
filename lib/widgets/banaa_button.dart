import 'package:auto_size_text/auto_size_text.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_clip_rrect.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_container.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
import 'package:educ_student/core/brand_colors.dart';
import 'package:educ_student/widgets/banaa_button_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BanaaButton extends StatelessWidget {
  const BanaaButton({
    super.key,
    required this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.onPressed,
    this.textColor,
    this.backgroundColor,
    this.borderColor,
    this.shadowColor,
    this.isEnabled = true,
    this.autoSizeGroup,
    this.maxLines,
  })  : _isSurface = false,
        _accentColor = null;

  const BanaaButton.accent({
    super.key,
    required this._accentColor,
    required this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.onPressed,
    this.textColor,
    this.backgroundColor,
    this.borderColor,
    this.shadowColor,
    this.isEnabled = true,
    this.autoSizeGroup,
    this.maxLines,
  })  : _isSurface = false;

  const BanaaButton.surface({
    super.key,
    required this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.backgroundColor,
    this.onPressed,
    this.isEnabled = true,
    this.autoSizeGroup,
    this.maxLines,
  })  : borderColor = null,
        shadowColor = null,
        textColor = null,
        _isSurface = true,
        _accentColor = null;

  const BanaaButton.accentSurface({
    super.key,
    required this._accentColor,
    this.backgroundColor,
    required this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.onPressed,
    this.isEnabled = true,
    this.autoSizeGroup,
    this.maxLines,
  })  : borderColor = null,
        shadowColor = null,
        textColor = null,
        _isSurface = true;

  final String label;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onPressed;
  final Color? textColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? shadowColor;
  final bool isEnabled;
  final AutoSizeGroup? autoSizeGroup;
  final int? maxLines;

  final bool _isSurface;
  final Color? _accentColor;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BanaaButtonCubit(),
      child: BlocBuilder<BanaaButtonCubit, BanaaButtonState>(
        builder: (context, state) {
          final cubit = context.read<BanaaButtonCubit>();
          final isFocused = state is BanaaButtonFocused;
          final isHovered = state is BanaaButtonHovered;
          final isPressed = state is BanaaButtonPressed;

          const double elevation = 3;
          const initialMargin = EdgeInsets.fromLTRB(0, 0, elevation, elevation);
          const pressedMargin = EdgeInsets.fromLTRB(elevation, elevation, 0, 0);

          return Focus(
            onFocusChange: isEnabled ? cubit.onFocusChange : null,
            onKeyEvent: (node, event) {
              switch (event.logicalKey) {
                case LogicalKeyboardKey.enter:
                case LogicalKeyboardKey.space:
                  if (isEnabled) {
                    cubit.simulateTap();
                    onPressed?.call();
                    return KeyEventResult.handled;
                  }
                  break;
              }

              return KeyEventResult.ignored;
            },
            child: MouseRegion(
              cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
              onHover: isEnabled ? cubit.onHover : null,
              onExit: isEnabled ? cubit.onExit : null,
              child: GestureDetector(
                onTap: isEnabled ? onPressed : null,
                onTapUp: isEnabled ? cubit.onTapUp : null,
                onTapDown: isEnabled ? cubit.onTapDown : null,
                onTapCancel: isEnabled ? cubit.onTapCancel : null,
                child: SmoothClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    topRight: Radius.circular(!isEnabled ? 16 : 12),
                    bottomLeft: Radius.circular(!isEnabled ? 16 : 12),
                    bottomRight: const Radius.circular(12),
                  ),
                  // child: ColorFiltered(//Ahmed - 2025-05-04 because of issue in button flip
                  //   colorFilter: ColorFilter.mode(//Ahmed - 2025-05-04 because of issue in button flip
                  //     !isEnabled ? Colors.black : Colors.transparent,//Ahmed - 2025-05-04 because of issue in button flip
                  //     BlendMode.hardLight,//Ahmed - 2025-05-04 because of issue in button flip
                  //   ),//Ahmed - 2025-05-04 because of issue in button flip
                  child: AnimatedSmoothContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(16),
                    margin: isPressed || isHovered ? pressedMargin : initialMargin,
                    constraints: const BoxConstraints(minHeight: 56),
                    decoration: ShapeDecoration(
                      color: isPressed || isHovered || isFocused
                          ? _getHoveredOrPressedColor(context)
                          : _getBackgroundColor(context),
                      shape: SmoothRectangleBorder(
                        smoothness: 0.6,
                        side: BorderSide(
                          width: 3,
                          color: _getBorderColor(context),
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      shadows: [
                        BoxShadow(
                          color: _getShadowColor(context),
                          offset: isPressed || isHovered ? const Offset(0, 0) : const Offset(elevation, elevation),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (prefixIcon != null) ...[
                          _buildIcon(context, prefixIcon!),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: AutoSizeText(
                            label,
                            textAlign: TextAlign.center,
                            group: autoSizeGroup,
                            maxLines: maxLines,
                            style: Omnes.w700.getStyle(
                              fontSize: 16,
                              color: _getLabelTextColor(context),
                            ),
                          ),
                        ),
                        if (suffixIcon != null) ...[
                          const SizedBox(width: 8),
                          _buildIcon(context, suffixIcon!),
                        ],
                      ],
                    ),
                  ),
                  // ),//Ahmed - 2025-05-04 because of issue in button flip
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  DefaultSvgTheme _buildIcon(BuildContext context, Widget icon) {
    return DefaultSvgTheme(
      theme: SvgTheme(
        currentColor: _getLabelTextColor(context),
      ),
      child: IconTheme(
        data: IconThemeData(color: _getLabelTextColor(context)),
        child: icon,
      ),
    );
  }

  Color _getAccentColor(BuildContext context) {
    return _accentColor ?? BrandColors.primary1;
    // .alphaBlend(context.colorScheme.background, 0.8);
  }

  Color _getBackgroundColor(BuildContext context) {
    if (_isSurface) {
      return context.colorScheme.surface;
    }
    return backgroundColor ?? _getAccentColor(context);
  }

  Color _getShadowColor(BuildContext context) {
    return shadowColor ?? _getAccentColor(context).darken();
    // context.colorScheme.primary.alphaBlend(context.colorScheme.background, 0.7);
  }

  Color _getBorderColor(BuildContext context) {
    if (_isSurface) {
      return _getAccentColor(context);
    }
    return borderColor ?? _getBackgroundColor(context);
  }

  Color _getHoveredOrPressedColor(BuildContext context) {
    return _getBackgroundColor(context).alphaBlend(context.colorScheme.surface, 0.8);
  }

  Color _getLabelTextColor(BuildContext context) {
    final bgColor = _getBackgroundColor(context);
    if (_isSurface) {
      return textColor ?? _getAccentColor(context);
    } else if (_accentColor != null) {
      final isBgDark = bgColor.computeLuminance() < 0.5;
      return textColor ?? (isBgDark ? Colors.white : Colors.black);
    } else {
      return context.colorScheme.onInverseSurface;
    }
  }
}
