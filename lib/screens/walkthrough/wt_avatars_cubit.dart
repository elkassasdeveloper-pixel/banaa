import 'package:educ_core/constants/enums.dart';
import 'package:educ_core/data/models/avatar.dart';
import 'package:educ_core/data/repositories/avatar_repository.dart';
import 'package:educ_core/utils/result.dart';
import 'package:educ_student/core/constants.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WtAvatarsCubit extends Cubit<WtAvatarsState> {
  WtAvatarsCubit() : super(WtAvatarsInitial());

  final formKey = GlobalKey<FormState>();
  final _avatarRepository = AvatarRepository();

  Avatar? selectedAvatar;
  List<Avatar> avatars = [];

  Gender gender = Consts.defaultGender;

  Future<void> fetchAvatars([bool? isMale]) async {
    emit(WtAvatarsLoading());

    final result =
        await _avatarRepository.getAllAvatars(isMale: isMale ?? gender.isMale);

    await result.fold(
      (data) {
        avatars = data;
        emit(WtAvatarsLoaded());

        if (avatars.isNotEmpty) {
          onAvatarChanged(avatars.first);
        }
      },
      (failure) => emit(WtAvatarsError(failure)),
    );
  }

  void onAvatarChanged(Avatar avatar) {
    selectedAvatar = avatar;
    emit(WtAvatarsChanged());
  }

  void reset() {}
}

@immutable
sealed class WtAvatarsState {}

final class WtAvatarsInitial extends WtAvatarsState {}

final class WtAvatarsLoading extends WtAvatarsState {}

final class WtAvatarsLoaded extends WtAvatarsState {}

final class WtAvatarsChanged extends WtAvatarsState {}

final class WtAvatarsError extends WtAvatarsState {
  final Failure failure;

  WtAvatarsError(this.failure);
}
