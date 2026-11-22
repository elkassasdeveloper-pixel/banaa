import 'dart:math';

import 'package:educ_core/utils/helpers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnBoardingCubit extends Cubit<OnBoardingState> {
  final int pagesCount;

  OnBoardingCubit({required this.pagesCount}) : super(OnBoardingState()) {
    pageController = PageController(
      onAttach: (position) {
        doPostFrame((_) =>
            onScroll(position.pixels, position.maxScrollExtent, pagesCount));
      },
    );
  }

  late final PageController pageController;

  // void initProgress() {
  //   emit(state.copyWith(progress: 1 / pagesCount));
  // }

  void onNextPressed() {
    pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  void onScroll(double pixels, double maxScrollExtent, int pagesCount) {
    final angle = (4 * pi * (pixels / maxScrollExtent));
    final pageExtent = maxScrollExtent / pagesCount;
    final progress = (pixels + pageExtent) / (maxScrollExtent + pageExtent);
    emit(state.copyWith(angle: angle, progress: progress));
  }

  void onPageChanged(int value) {
    emit(state.copyWith(currentIndex: value));
  }
}

class OnBoardingState {
  final int currentIndex;
  final double angle;
  final double progress;

  OnBoardingState({
    this.currentIndex = 0,
    this.angle = 0.0,
    this.progress = 0.0,
  });

  OnBoardingState copyWith({
    int? currentIndex,
    double? angle,
    double? progress,
  }) {
    return OnBoardingState(
      currentIndex: currentIndex ?? this.currentIndex,
      angle: angle ?? this.angle,
      progress: progress ?? this.progress,
    );
  }
}
