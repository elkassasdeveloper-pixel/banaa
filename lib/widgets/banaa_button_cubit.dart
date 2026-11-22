import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BanaaButtonCubit extends Cubit<BanaaButtonState> {
  BanaaButtonCubit() : super(BanaaButtonInitial());

  void onHover(PointerHoverEvent event) {
    if (event.kind == PointerDeviceKind.mouse) {
      emit(BanaaButtonHovered());
    }
  }

  void onExit(PointerExitEvent event) {
    emit(BanaaButtonInitial());
  }

  void onTapDown(TapDownDetails event) {
    emit(BanaaButtonPressed());
  }

  void onTapUp(TapUpDetails event) {
    emit(BanaaButtonInitial());
  }

  void onTapCancel() {
    emit(BanaaButtonInitial());
  }

  void onFocusChange(bool hasFocus) {
    if (hasFocus) {
      emit(BanaaButtonFocused());
    } else {
      emit(BanaaButtonInitial());
    }
  }

  void simulateTap() {
    emit(BanaaButtonPressed());
    Future.delayed(
      const Duration(milliseconds: 200),
      () => emit(BanaaButtonInitial()),
    );
  }
}

@immutable
abstract class BanaaButtonState {}

class BanaaButtonInitial extends BanaaButtonState {}

class BanaaButtonLoading extends BanaaButtonState {}

class BanaaButtonHovered extends BanaaButtonState {}

class BanaaButtonFocused extends BanaaButtonState {}

class BanaaButtonPressed extends BanaaButtonState {}

class BanaaButtonDisabled extends BanaaButtonState {}
