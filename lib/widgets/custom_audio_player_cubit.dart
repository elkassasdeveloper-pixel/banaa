import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

class CustomAudioPlayerCubit extends Cubit<CustomAudioPlayerState> {
  final AudioPlayer player;

  CustomAudioPlayerCubit(this.player) : super(CustomAudioPlayerInitial());

  Future<void> initialize(String url) async {
    emit(CustomAudioPlayerLoading());
    try {
      await player.setUrl(url);
      emit(CustomAudioPlayerInitialized());
    } catch (e) {
      emit(CustomAudioPlayerError(e.toString()));
    }
  }

  void togglePlayPause() {
    if (player.playing) {
      player.pause();
    } else {
      player.play();
    }
  }

  @override
  Future<void> close() {
    player.dispose();
    return super.close();
  }
}

@immutable
abstract class CustomAudioPlayerState {}

class CustomAudioPlayerInitial extends CustomAudioPlayerState {}

class CustomAudioPlayerLoading extends CustomAudioPlayerState {}

class CustomAudioPlayerInitialized extends CustomAudioPlayerState {}

class CustomAudioPlayerError extends CustomAudioPlayerState {
  final String message;

  CustomAudioPlayerError(this.message);
}
