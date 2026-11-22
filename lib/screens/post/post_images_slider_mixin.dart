import 'dart:math' as math;

import 'package:educ_core/utils/helpers.dart';
import 'package:educ_student/screens/post/post_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

mixin PostImagesSliderMixin on Cubit<PostState> {
  // late final SyncPageController syncPageController;
  late final PageController primaryPageController;
  late final PageController secondaryPageController;
  int currentIndex = 0;

  void initPageController() {
    primaryPageController = PageController()..addListener(onScrollUpdate);
    secondaryPageController = PageController()..addListener(onScrollUpdate);
  }

  double page(PageController ctrl) {
    try {
      return ctrl.page ?? ctrl.initialPage.toDouble();
    } catch (e) {
      return ctrl.initialPage.toDouble();
    }
  }

  void onPageChanged(int index) {
    // print("pageChanged $index");
    currentIndex = index;
    emit(PostImagesSliderPageChanged());
  }

  double getIndicatorWidth(int index, int pagesLength, PageController ctrl) {
    const maxIndicatorWidth = 16.0;
    const minIndicatorWidth = 4.0;
    final page = this.page(ctrl);

    final currentIndex = page.floor();

    if (currentIndex == index) {
      return math.max(
          maxIndicatorWidth -
              maxIndicatorWidth * (page - page.floor()) +
              minIndicatorWidth,
          minIndicatorWidth);
    } else if (index == currentIndex + 1) {
      return math.max(
        maxIndicatorWidth * (page - page.floor()) + minIndicatorWidth,
        minIndicatorWidth,
      );
    } else {
      return minIndicatorWidth;
    }
  }

  void onScrollUpdate() {
    emit(PostImagesSliderScrolling());
  }

// Future<void> animateToPage(int index) async {
//   await pageController.animateToPage(
//     index,
//     duration: const Duration(milliseconds: 300),
//     curve: Curves.ease,
//   );
// }
}

class SyncPageController {
  final PageController primary;
  PageController? secondary;

  SyncPageController(this.primary) {
    primary.addListener(_syncScrollPrimary);
  }

  double get page {
    try {
      return primary.page ?? primary.initialPage.toDouble();
    } catch (_) {
      return primary.initialPage.toDouble();
    }
  }

  void attachSecondary() {
    secondary = PageController(
      onAttach: (position) {
        doPostFrame((_) => secondary?.jumpTo(page));
      },
    );
    // secondary?.addListener(_syncScrollSecondary);
  }

  void _syncScrollPrimary() {
    if (secondary != null && primary.hasClients) {
      final page = primary.page ?? primary.initialPage.toDouble();
      secondary!.jumpTo(page);
    }
  }

  void _syncScrollSecondary() {
    final secondary = this.secondary;
    if (secondary != null && secondary.hasClients) {
      final page = secondary.page ?? secondary.initialPage.toDouble();
      primary.jumpTo(page);
    }
  }

  void dispose() {
    primary.removeListener(_syncScrollPrimary);
    secondary?.removeListener(_syncScrollSecondary);
  }
}
