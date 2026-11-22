import 'package:educ_core/data/models/avatar.dart';
import 'package:educ_core/data/models/user.dart';
import 'package:educ_core/data/repositories/user_repository.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/services/dio_helper.dart';
import 'package:educ_core/data/repositories/avatar_repository.dart';
import 'package:educ_student/screens/other/settings_cubit.dart';
import 'package:educ_student/widgets/loading_indicator.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EditAvatarCubit extends Cubit<EditAvatarState> {
  EditAvatarCubit() : super(EditAvatarInitialState());
  List<Avatar> avatars = [];
  Avatar selectedAvatar = Avatar.fromMap({});
  final formKey = GlobalKey<FormState>();
  final UserRepository userRepository = UserRepository();
  final AvatarRepository avatarRepository = AvatarRepository();
  User? user;

  Future<void> _loadCurrentUser() async {
    // Adjust to however the app currently exposes the logged-in user's id.
    final userId = DioHelper.userId!;

    // Assumes User exposes level/totalScore/totalAttempts/isVerified/isLocked/streak
    // matching UpdateUserDto — adjust field names below if they differ.
    final result = await userRepository.getUser(userId);

    result.fold((user) {
      this.user = user;
    }, (failure) => emit(GetAvatarsErrorState()));
  }

  Future<void> getAvatars(BuildContext context) async {
    emit(GetAvatarsLoadingState());

    await _loadCurrentUser();

    final result = await avatarRepository.getAllAvatars(
      isMale: user?.isMale ?? true,
    );

    result.fold(
          (avatars) {
        if (avatars.isEmpty) return;

        this.avatars = avatars;

        final savedAvatarId = context.read<SettingsCubit>().prefs.avatarId;
        selectedAvatar = avatars.firstWhere(
              (element) => element.id.toString() == savedAvatarId,
          orElse: () => avatars.first,
        );

        emit(GetAvatarsSuccessState());
      },
          (failure) => emit(GetAvatarsErrorState()),
    );
  }

  void onAvatarChanged(BuildContext context, Avatar avatar) {
    selectedAvatar = avatar;
    context.read<SettingsCubit>().prefs.avatarId = avatar.id.toString();
    emit(AssistanChanged());
  }

  Future<void> save(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      _showLoadingDialog(
        context,
        invocation: () => context.read<SettingsCubit>().saveChanges(),
        message: "saving_changes".tr(),
      ).then((value) {if(context.mounted) context.pop();});
    }
  }

  Future<void> _showLoadingDialog(
    BuildContext context, {
    required Future Function() invocation,
    String? message,
  }) async {
    BuildContext popContext = context;
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (context) {
        popContext = context;
        return LoadingIndicator(message: message);
      },
    );

    await invocation().then((_) {
      if(context.mounted)  Navigator.pop(popContext);
    });
  }
}

abstract class EditAvatarState {}

class EditAvatarInitialState extends EditAvatarState {}

enum EditAvatarStatus { loading, ready, submitting, success, failure }

class GetAvatarsLoadingState extends EditAvatarState {}

class GetAvatarsErrorState extends EditAvatarState {}

class GetAvatarsSuccessState extends EditAvatarState {}

class AssistanChanged extends EditAvatarState {}
