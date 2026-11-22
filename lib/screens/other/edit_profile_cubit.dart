import 'package:educ_core/data/models/user.dart';
import 'package:educ_core/data/models/dtos/update_user_dto.dart';
import 'package:educ_core/data/repositories/user_repository.dart';
import 'package:educ_core/services/dio_helper.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit({UserRepository? userRepository})
      : userRepository = userRepository ?? UserRepository(),
        super(const EditProfileState()) {
    _loadCurrentUser();
  }

  final UserRepository userRepository;

  final formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();

  Future<void> _loadCurrentUser() async {
    // Adjust to however the app currently exposes the logged-in user's id.
    final userId = DioHelper.userId!;

    // Assumes User exposes level/totalScore/totalAttempts/isVerified/isLocked/streak
    // matching UpdateUserDto — adjust field names below if they differ.
    final result = await userRepository.getUser(userId);

    result.fold(
          (user) {
        firstNameController.text = user.firstName;
        lastNameController.text = user.lastName;
        emailController.text = user.email;
        emit(state.copyWith(status: EditProfileStatus.ready, user: user));
      },
          (failure) => emit(state.copyWith(
        status: EditProfileStatus.failure,
        errorMessage: failure.failureCode,
      )),
    );
  }

  Future<void> save() async {
    final user = state.user;
    if (user == null || !formKey.currentState!.validate()) return;

    emit(state.copyWith(status: EditProfileStatus.submitting));

    // Preserves the rest of the user's data untouched; only the edited
    // fields change. Password is left blank unless the user typed a new
    // one — confirm with your backend that an empty string means "no change".
    final dto = UpdateUserDto(
      id: user.id,
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      biography: user.biography,
      email: emailController.text,
      password: "",
      isMale: user.isMale,
      age: user.age,
      avatarId: user.avatarId,
      countryCode: user.countryCode,
      roleId: user.roleId,
      knowledgeLevelId: user.knowledgeLevelId,
      languageCode: user.languageCode,
      level: user.level,
      totalScore: user.totalScore,
      totalAttempts: user.totalAttempts,
      isVerified: user.isVerified,
      isLocked: user.isLocked,
      streak: user.streak,
    );

    final result = await userRepository.updateUser(dto);

    result.fold(
          (_) => emit(state.copyWith(status: EditProfileStatus.success)),
          (failure) => emit(state.copyWith(
        status: EditProfileStatus.failure,
        errorMessage: failure.failureCode,
      )),
    );
  }

  @override
  Future<void> close() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    return super.close();
  }
}

enum EditProfileStatus { loading, ready, submitting, success, failure }

class EditProfileState {
  final EditProfileStatus status;
  final User? user;
  final String? errorMessage;

  const EditProfileState({
    this.status = EditProfileStatus.loading,
    this.user,
    this.errorMessage,
  });

  EditProfileState copyWith({
    EditProfileStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return EditProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}