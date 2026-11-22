import 'dart:convert';

import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_student/core/brand_colors.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class ReadMoreQuill extends StatelessWidget {
  final String body;
  final bool isExpanded;

  const ReadMoreQuill({
    super.key,
    required this.body,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    try {
      final doc = quill.Document.fromJson(jsonDecode(body));
      final controller = quill.QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );

      if (isExpanded) {
        return quill.QuillEditor.basic(
          controller: controller,
        );
      }


      final plainText = controller.document.toPlainText().replaceAll('\n', ' ');
      final textStyle = Omnes.w400.getStyle(fontSize: 16.0, color: context.colorScheme.primary);

      final textPainter = TextPainter(
        text: TextSpan(text: plainText, style: textStyle),
        maxLines: 5,
        textDirection: Directionality.of(context),
      )..layout(maxWidth: MediaQuery.of(context).size.width);

      final needsReadMore = textPainter.didExceedMaxLines;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 120,
            child: quill.QuillEditor(
              controller: controller,
              scrollController: ScrollController(),
              focusNode: FocusNode(),
            ),
          ),
          if (needsReadMore)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                "read_more".tr(),
                style: Omnes.w400.getStyle(
                  fontSize: 16.0,
                  color: BrandColors.primary1,
                ).copyWith(
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.solid,
                  decorationColor: BrandColors.primary1.withValues(alpha: 0.5),
                  decorationThickness: 1,
                ),
              ),
            )
        ],
      );
    } catch (e) {
      return Text(
        body,
        style: Omnes.w400.getStyle(fontSize: 16.0, color: context.colorScheme.primary),
      );
    }
  }
}
