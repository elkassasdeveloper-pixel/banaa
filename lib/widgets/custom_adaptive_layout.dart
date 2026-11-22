import 'package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart';
import 'package:material_ui/material_ui.dart';


class CustomAdaptiveLayout extends AdaptiveLayout {
  const CustomAdaptiveLayout({
    super.key,
    this.smallBody,
    this.mediumBody,
    // this.mediumLargeBody,
    this.largeBody,
  }) : super();

  final WidgetBuilder? smallBody;
  final WidgetBuilder? mediumBody;
  // final WidgetBuilder? mediumLargeBody;
  final WidgetBuilder? largeBody;

  @override
  SlotLayout? get body {
    return SlotLayout(
      config: {
        // if (mediumLargeBody != null)
        //   Breakpoints.large: SlotLayout.from(
        //     key: const Key('Medium_LARGE_BODY'),
        //     builder: mediumLargeBody,
        //   ),
        if (smallBody != null) Breakpoints.small: SlotLayout.from(key: const Key('SMALL_BODY'), builder: smallBody),
        if (mediumBody != null) // todo //kohla edit from medium to mediumAndUp 1-10-2024
          Breakpoints.mediumAndUp: SlotLayout.from(key: const Key('MEDIUM_BODY'), builder: mediumBody),
        if (largeBody != null) Breakpoints.large: SlotLayout.from(key: const Key('LARGE_BODY'), builder: largeBody),
      },
    );
  }
}
