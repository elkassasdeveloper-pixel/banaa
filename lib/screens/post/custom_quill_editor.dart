import 'package:easy_localization/easy_localization.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';

class CustomQuillEditor extends StatelessWidget {
  final QuillController controller;
  final bool isFullScreen;
  final bool readOnly;

  const CustomQuillEditor({super.key, required this.controller, this.isFullScreen = false, this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 16)),
      child: Column(
        children: [
          _CustomEditorToolbar(controller: controller, isFullScreen: isFullScreen),
          const _Divider(),
          if (isFullScreen)
            Expanded(
              child: _CustomEditor(controller: controller, isFullScreen: true, readOnly: readOnly),
            )
          else
            _CustomEditor(controller: controller, isFullScreen: false, readOnly: readOnly),
        ],
      ),
    );
  }
}

class _CustomEditor extends StatelessWidget {
  final QuillController controller;
  final bool isFullScreen;
  final bool readOnly;

  const _CustomEditor({required this.controller, required this.isFullScreen, this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    return QuillEditor.basic(
      controller: controller,
      config: QuillEditorConfig(
        autoFocus: isFullScreen,
        scrollable: true,
        minHeight: isFullScreen ? null : 200,
        maxHeight: isFullScreen ? null : 300,
        expands: isFullScreen,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        placeholder: "write_content_here".tr(),
        customStyles: DefaultStyles(
          link: TextStyle(color: Theme.of(context).tabBarTheme.indicatorColor, decoration: TextDecoration.underline, decorationStyle: TextDecorationStyle.solid, decorationColor: context.colorScheme.primary.withValues(alpha: 0.5)),
        ),
      ),
    );
  }
}

class _CustomEditorToolbar extends StatelessWidget {
  final QuillController controller;
  final bool isFullScreen;

  const _CustomEditorToolbar({required this.controller, required this.isFullScreen});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FormatPainterCubit(),
      child: BlocBuilder<FormatPainterCubit, FormatPainterState>(
        builder: (context, state) {
          return QuillSimpleToolbar(
            controller: controller,
            config: QuillSimpleToolbarConfig(
              showFontSize: true,
              showColorButton: true,
              showBoldButton: true,
              showListNumbers: true,
              showListBullets: true,

              // ❌ كل الباقي false
              showFontFamily: false,
              showItalicButton: false,
              showSmallButton: false,
              showUnderLineButton: false,
              showLineHeightButton: false,
              showStrikeThrough: false,
              showInlineCode: false,
              showBackgroundColorButton: false,
              showClearFormat: false,
              showAlignmentButtons: false,
              showLeftAlignment: false,
              showCenterAlignment: false,
              showRightAlignment: false,
              showJustifyAlignment: false,
              showHeaderStyle: false,
              showListCheck: false,
              showCodeBlock: false,
              showQuote: false,
              showIndent: false,
              showLink: false,
              showUndo: false,
              showRedo: false,
              showDirection: false,
              showSearchButton: false,
              showSubscript: false,
              showSuperscript: false,
              showDividers: false,


      /*        customButtons: [
                QuillToolbarCustomButtonOptions(
                  tooltip: state.hasFormat ? "إلغاء التنسيق" : "نسخ التنسيق",
                  icon: Stack(
                    children: [
                      Icon(Icons.format_paint, color: state.hasFormat ? Colors.grey : Colors.black),
                      // if (state.hasFormat)
                      //   Positioned(
                      //     top: 0,
                      //     right: 0,
                      //     child: Icon(Icons.cancel, size: 12, color: context.colorS.error),
                      //   ),
                    ],
                  ),
                  onPressed: () {
                    final style = controller.getSelectionStyle();
                    context.read<FormatPainterCubit>().toggleCopy(style);
                  },
                ),
                // Apply Format
                QuillToolbarCustomButtonOptions(
                  tooltip: "تطبيق التنسيق",
                  icon: Icon(Icons.format_color_fill, color: state.hasFormat ? _getColorFromAttribute(state.format!.attributes['color']?.value) : Colors.grey),
                  onPressed: state.hasFormat
                      ? () {
                          final format = state.format!;
                          for (final attr in format.attributes.values) {
                            controller.formatSelection(attr);
                          }
                        }
                      : null, // 🔒 disabled when no format
                ),
                if (!isFullScreen)
                  QuillToolbarCustomButtonOptions(
                    tooltip: "open_in_fullscreen".tr(),
                    icon: const Icon(Icons.open_in_full_rounded),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return _FullscreenEditorDialog(controller: controller);
                        },
                      );
                    },
                  ),
              ],*/
            ),
          );
        },
      ),
    );
  }

  // Color? _getColorFromAttribute(dynamic value) {
  //   if (value is String) {
  //     try {
  //       String hex = value.replaceAll('#', '');
  //       if (hex.length == 6) hex = 'FF$hex'; // Add alpha if missing
  //       return Color(int.parse(hex, radix: 16));
  //     } catch (_) {
  //       return null;
  //     }
  //   }
  //   return null;
  // }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(thickness: 1, color: context.colorScheme.outline);
  }
}

// class _FullscreenEditorDialog extends StatelessWidget {
//   final QuillController controller;
//
//   const _FullscreenEditorDialog({required this.controller});
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog.fullscreen(
//       child: Scaffold(
//         body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               SectionCard(
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(width: 8.0),
//                     IconButton.outlined(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context), color: context.colorScheme.error),
//                     const SizedBox(width: 12),
//                     Expanded(child: _CustomEditorToolbar(controller: controller, isFullScreen: true)),
//                   ],
//                 ),
//               ),
//               // const _Divider(),
//               Expanded(
//                 child: SectionCard(
//                   child: Expanded(child: _CustomEditor(controller: controller, isFullScreen: true)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class FormatPainterCubit extends Cubit<FormatPainterState> {
  FormatPainterCubit() : super(FormatPainterState());

  void toggleCopy(Style currentSelection) {
    if (state.format != null) {
      emit(FormatPainterState()); // clear
    } else {
      emit(FormatPainterState(format: currentSelection));
    }
  }

  void clear() => emit(FormatPainterState());
}

class FormatPainterState {
  final Style? format;

  bool get hasFormat => format != null;

  FormatPainterState({this.format});
}
