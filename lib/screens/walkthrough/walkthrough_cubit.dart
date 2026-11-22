import 'package:educ_core/utils/result.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef OnLoadedCallback = void Function(WalkthroughState state);

class WalkthroughCubit extends Cubit<WalkthroughState> {
  WalkthroughCubit() : super(WalkthroughInitial());

  final pageController = PageController();

  int currentIndex = 0;

  void onPageChanged(int value) {
    currentIndex = value;
    emit(WalkthroughChanged());
  }

  Future<void> goToPage(int index) async {
    await pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
    );

    currentIndex = index;
    emit(WalkthroughChanged());
  }

  Future<void> goPreviousView() async {
    await pageController.previousPage(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  Future<void> goNextView() async {
    await pageController.nextPage(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  bool validateForms(
    GlobalKey<FormState> userDetailsFormKey,
    GlobalKey<FormState> avatarsSelectFormKey,
    GlobalKey<FormState> collectionSelectFormKey,
    GlobalKey<FormState> levelSelectFormKey,
  ) {
    if (currentIndex == 0) {
      if (userDetailsFormKey.currentState?.validate() == false) {
        goToPage(0);
        return false;
      }
    } else if (currentIndex == 1) {
      if (avatarsSelectFormKey.currentState?.validate() == false) {
        goToPage(1);
        return false;
      }
    } else if (currentIndex == 2) {
      if (collectionSelectFormKey.currentState?.validate() == false) {
        goToPage(2);
        return false;
      }
    } else if (currentIndex == 3) {
      if (levelSelectFormKey.currentState?.validate() == false) {
        goToPage(3);
        return false;
      }
    }

    return true;
  }
}



abstract class WalkthroughState {}

class WalkthroughInitial extends WalkthroughState {}

class WalkthroughChanged extends WalkthroughState {}

class WalkthroughError extends WalkthroughState {
  final Failure failure;

  WalkthroughError(this.failure);
}
