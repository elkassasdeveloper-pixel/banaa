import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_student/core/brand_colors.dart';
import 'package:educ_student/core/extensions.dart';
import 'package:material_ui/material_ui.dart';

class ReadMoreText extends StatelessWidget {
  final String text;
  final bool isExpanded;

  const ReadMoreText({super.key, required this.text, this.isExpanded = false});

  @override
  Widget build(BuildContext context) {
    if (isExpanded) {
      return _expandedText(context);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        // TextPainter to measure text length
        final textPainter = TextPainter(
          text: TextSpan(
            text: text,
            style: Omnes.w400.getStyle(fontSize: 16.0, color: context.colorScheme.primary),
          ),
          maxLines: isExpanded ? null : 5,
          textDirection: Directionality.of(context),
        );

        final rmTextPainter = TextPainter(
          text: TextSpan(
            text: "read_more".tr(),
            style: Omnes.w400.getStyle(fontSize: 16.0, color: BrandColors.primary1).copyWith(
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.solid,
                  decorationColor: BrandColors.primary1.withValues(alpha: 0.5),
                  decorationThickness: 1,
                ),
          ),
          maxLines: isExpanded ? null : 5,
          textDirection: Directionality.of(context),
        );

        textPainter.layout(maxWidth: constraints.maxWidth);
        rmTextPainter.layout(maxWidth: constraints.maxWidth);

        if (textPainter.didExceedMaxLines) {
          final textRange = textPainter.getPositionForOffset(
            Offset(0, textPainter.height),
          );

          final rmTextRange = rmTextPainter.getPositionForOffset(
            Offset(0, rmTextPainter.height),
          );

          return Text.rich(
            maxLines: isExpanded ? null : 5,
            textDirection: text.getTextDirection(),
            style: Omnes.w400.getStyle(fontSize: 16.0, color: context.colorScheme.primary),
            TextSpan(
              text: text.substring(0, textRange.offset - rmTextRange.offset),
              children: [
                const TextSpan(text: "   "),
                TextSpan(
                  text: "read_more".tr(),
                  style: Omnes.w400.getStyle(fontSize: 16.0, color: BrandColors.primary1).copyWith(
                        decoration: TextDecoration.underline,
                        decorationStyle: TextDecorationStyle.solid,
                        decorationColor: BrandColors.primary1.withValues(alpha: 0.5),
                        decorationThickness: 1,
                      ),
                ),
              ],
            ),
          );
        } else {
          return _expandedText(context);
        }
      },
    );
  }

  Widget _expandedText(BuildContext context) {
    return Text(
      text,
      textDirection: text.getTextDirection(),
      style: Omnes.w400.getStyle(fontSize: 16.0, color: context.colorScheme.primary),
    );
  }
}
