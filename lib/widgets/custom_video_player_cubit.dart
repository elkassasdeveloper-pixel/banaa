import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomVideoPlayerCubit extends Cubit<CustomVideoPlayerState> {
  CustomVideoPlayerCubit(this.controller) : super(CustomVideoPlayerInitial());

  final VideoPlayerController controller;

  Future<void> initialize() async {
    emit(CustomVideoPlayerLoading());
    controller.removeListener(controllerListener);
    controller.addListener(controllerListener);
    await controller.initialize();
  }

  void controllerListener() {
    if (controller.value.hasError) {
      emit(CustomVideoPlayerError(
        Failure(controller.value.errorDescription ?? ""),
      ));
    } else if (controller.value.isInitialized) {
      emit(CustomVideoPlayerInitialized());
    }
  }

  void reload() {
    emit(CustomVideoPlayerLoading());
    controller.removeListener(controllerListener);
    controller.addListener(controllerListener);
    controller.initialize();
  }

  @override
  Future<void> close() async {
    await controller.dispose();
    return super.close();
  }
}

@immutable
abstract class CustomVideoPlayerState {}

class CustomVideoPlayerInitial extends CustomVideoPlayerState {}

class CustomVideoPlayerLoading extends CustomVideoPlayerState {}

class CustomVideoPlayerInitialized extends CustomVideoPlayerState {}

class CustomVideoPlayerBuffering extends CustomVideoPlayerState {}

class CustomVideoPlayerError extends CustomVideoPlayerState {
  final Failure failure;

  CustomVideoPlayerError(this.failure);
}
