import 'package:educ_core/constants/enums.dart';
import 'package:educ_core/data/models/dtos/register_guest_dto.dart';
import 'package:educ_core/data/models/dtos/register_user_dto.dart';
import 'package:educ_core/data/models/user.dart';
import 'package:educ_core/data/repositories/auth_repository.dart';
import 'package:educ_core/error/failures.dart';
import 'package:educ_core/services/cache_helper.dart';
import 'package:educ_core/utils/io_web/io_web_utils.dart' as io_web;
import 'package:educ_core/utils/result.dart';
import 'package:educ_student/core/helpers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit() : super(SignUpInitial());

  final _authRepository = AuthRepository();

  bool isGuest = false;
  bool passwordObscure = true;

  final formKey = GlobalKey<FormState>();
  final autofillGroupKey = GlobalKey<AutofillGroupState>();
  final knowledgeLevelFormKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  AccountKnowledgeLevel knowledgeLevel = AccountKnowledgeLevel.beginner;

  Future<bool?> isEmailExist() async {
    emit(SignUpLoading());

    final result =
        await _authRepository.isEmailExist(emailController.text.trim());

    return result.fold(
      (data) {
        if (data) {
          emit(SignUpError(const Failure("http_errors.User_ExistingEmail")));
          return true;
        } else {
          emit(SignUpInitial());
          return false;
        }
      },
      (failure) {
        emit(SignUpError(failure));
        return null;
      },
    );
  }

  Future<void> signUp({
    required String firstName,
    required String lastName,
    required Gender gender,
    required int age,
    required int avatarId,
    required String countryCode,
    required String rootCollectionId,
    required String languageCode,
  }) async {
    if (state is SignUpLoading) return;

    emit(SignUpLoading());

    final Result<Unit> result;

    final deviceId = io_web.deviceID;
    if (deviceId == null) {
      emit(SignUpError(const FailedToGetDeviceIdFailure()));
      return;
    }

    if (isGuest) {
      result = await _authRepository.guestRegister(
        GuestRegisterDto(
          firstName: firstName.trim(),
          lastName: lastName.trim(),
          deviceId: deviceId,
          isMale: gender.isMale,
          age: age,
          avatarId: avatarId,
          countryCode: countryCode,
          knowledgeLevelId: knowledgeLevel.id,
          languageCode: languageCode,
          collectionId: rootCollectionId,
          assistantId: "1",
        ),
      );
    } else {
      result = await _authRepository.userRegister(
        UserRegisterDto(
          firstName: firstName.trim(),
          lastName: lastName.trim(),
          email: emailController.text,
          password: passwordController.text,
          isMale: gender.isMale,
          age: age,
          avatarId: avatarId,
          countryCode: countryCode,
          knowledgeLevelId: knowledgeLevel.id,
          languageCode: languageCode,
          collectionId: rootCollectionId,
          assistantId: "1",
        ),
      );
    }

    await result.fold(
      (data) async {
        final userResult = await fetchCurrentUser();
        return userResult.fold(
          (user) {
            TextInput.finishAutofillContext(shouldSave: true);
            CacheHelper.saveData(key: "user_id", value: user.id);
            return emit(SignUpSuccess(user));
          },
          (failure) => emit(SignUpError(failure)),
        );
      },
      (failure) => emit(SignUpError(failure)),
    );
  }

  void onKnowledgeLevelChanged(AccountKnowledgeLevel? value) {
    if (value != null) {
      knowledgeLevel = value;
    }
    emit(SignUpChanged());
  }

  void setIsGuest(bool value) {
    isGuest = value;
  }

  void togglePasswordVisible() {
    passwordObscure = !passwordObscure;
    emit(SignUpChanged());
  }

  void reset() {
    formKey.currentState?.reset();
    knowledgeLevelFormKey.currentState?.reset();

    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    knowledgeLevel = AccountKnowledgeLevel.beginner;
    isGuest = false;
    emit(SignUpInitial());
  }
}

abstract class SignUpState {}

class SignUpInitial extends SignUpState {}

class SignUpLoading extends SignUpState {}

class SignUpSuccess extends SignUpState {
  final User user;

  SignUpSuccess(this.user);
}

class SignUpChanged extends SignUpState {}

class SignUpError extends SignUpState {
  final Failure failure;

  SignUpError(this.failure);
}

// class SignUpState {
//   final bool isLoading;
//   final bool isGuest;
//   final String? error;
//   final bool isSuccess;
//   final Gender gender;
//   final Country? country;
//   final Collection? collection;
//   final KnowledgeLevel knowledgeLevel;
//   final Avatar? avatar;
//
//   SignUpState({
//     this.isLoading = false,
//     this.isGuest = false,
//     this.error,
//     this.isSuccess = false,
//     this.gender = Gender.female,
//     this.country,
//     this.collection,
//     this.knowledgeLevel = KnowledgeLevel.beginner,
//     this.avatar,
//   });
//
//   SignUpState copyWith({
//     bool? isLoading,
//     bool? isGuest,
//     String? error,
//     bool? isSuccess,
//     Gender? gender,
//     Country? country,
//     Collection? collection,
//     KnowledgeLevel? knowledgeLevel,
//     Avatar? avatar,
//   }) {
//     return SignUpState(
//       isLoading: isLoading ?? this.isLoading,
//       isGuest: isGuest ?? this.isGuest,
//       error: error,
//       isSuccess: isSuccess ?? this.isSuccess,
//       gender: gender ?? this.gender,
//       country: country ?? this.country,
//       collection: collection ?? this.collection,
//       knowledgeLevel: knowledgeLevel ?? this.knowledgeLevel,
//       avatar: avatar ?? this.avatar,
//     );
//   }
// }
