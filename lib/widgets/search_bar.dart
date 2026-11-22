import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_input_border.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
import 'package:educ_student/core/assets.dart';
import 'package:material_ui/material_ui.dart';

class SearchBarWithFilter extends StatelessWidget {
  const SearchBarWithFilter({
    super.key,
    this.onFilterPressed,
    this.controller,
    this.onChanged,
    this.onSubmitted,
  });

  final VoidCallback? onFilterPressed;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              textInputAction: TextInputAction.search,
              maxLines: 1,
              onChanged: onChanged,
              onFieldSubmitted: onSubmitted,
              style: Omnes.w500.getStyle(
                fontSize: 16,
                color: context.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                constraints: const BoxConstraints.expand(height: 40),
                contentPadding: const EdgeInsets.all(8.0),
                filled: true,
                fillColor: context.colorScheme.primary.withValues(alpha: 0.06),
                border: SmoothInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                enabledBorder: SmoothInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                prefixIconConstraints: const BoxConstraints.tightFor(
                  width: 40,
                  height: 40,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    top: 8.0,
                    bottom: 8.0,
                    start: 16.0,
                    end: 8.0,
                  ),
                  child: SizedBox.square(
                    dimension: 16.0,
                    child: SvgPicture.asset(
                      Svgs.search,
                      colorFilter: context.colorScheme.primary.toColorFilter(),
                    ),
                  ),
                ),
                hintText: "search...".tr(),
                hintStyle: Omnes.w500.getStyle(
                  fontSize: 16,
                  color: context.colorScheme.primary.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          IconButton.filledTonal(
            onPressed: onFilterPressed,
            alignment: Alignment.center,
            icon: SvgPicture.asset(
              Svgs.filterPrefs,
              colorFilter: context.colorScheme.primary.toColorFilter(),
            ),
            constraints: const BoxConstraints.tightFor(width: 40, height: 40),
            style: IconButton.styleFrom(
              backgroundColor: context.colorScheme.primary.withValues(
                alpha: 0.06,
              ),
              foregroundColor: context.colorScheme.primary,
              shape: SmoothRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
