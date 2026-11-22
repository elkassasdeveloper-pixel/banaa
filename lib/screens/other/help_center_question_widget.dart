import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_student/core/brand_colors.dart';
import 'package:material_ui/material_ui.dart';

class HelpCenterQuestionWidget extends StatelessWidget {
  const HelpCenterQuestionWidget({
    super.key,
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> isExpanded = ValueNotifier<bool>(false);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                border: Border.all(
                  color: BrandColors.primary2,
                ),
                color: context.colorScheme.surfaceContainer,
              ),
              child: ValueListenableBuilder<bool>(
                valueListenable: isExpanded,
                builder: (context, expanded, child) {
                  return ExpansionTile(
                    shape: Border.all(style: BorderStyle.none),
                    backgroundColor: Colors.transparent,
                    showTrailingIcon: false,
                    childrenPadding: const EdgeInsets.only(
                      left: 16,
                      right: 20,
                      top: 20,
                      bottom: 20,
                    ),
                    onExpansionChanged: (val) {
                      isExpanded.value = val;
                    },
                    leading: Container(
                      width: 44,
                      height: 38,
                      decoration: BoxDecoration(
                        color: context.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        expanded ? Icons.remove : Icons.add,
                        color: context.colorScheme.onTertiary,
                      ),
                    ),
                    title: Text(
                      question,
                      style: Omnes.w500.getStyle(
                        fontSize: 16,
                        color: BrandColors.primary2,
                      ),
                    ),
                    children: [
                      Text(
                        answer,
                        style: Omnes.w500.getStyle(
                          fontSize: 16,
                          color: BrandColors.primary2,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
