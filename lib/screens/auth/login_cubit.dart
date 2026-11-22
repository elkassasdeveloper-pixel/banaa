import 'package:educ_core/data/models/user.dart';
import 'package:educ_core/data/repositories/auth_repository.dart';
import 'package:educ_core/error/failures.dart';
import 'package:educ_core/services/cache_helper.dart';
import 'package:educ_core/utils/helpers.dart';
import 'package:educ_core/utils/io_web/io_web_utils.dart' as io_web;
import 'package:educ_core/utils/result.dart';
import 'package:educ_student/core/helpers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  final _authRepository = AuthRepository();

  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool passwordObscure = true;
  bool rememberMe = false;

  Future<void> login() async {
    if (state is LoginLoading) return;

    final isValidate = formKey.currentState?.validate() ?? true;
    if (!isValidate) {
      return;
    }

    emit(LoginLoading());

    final loginResult = await _authRepository.userLogin(
      email: emailController.text,
      password: passwordController.text,
    );

    await loginResult.fold(
      (_) async {
        await Future.delayed(const Duration(seconds: 1));
        final userResult = await fetchCurrentUser();
        userResult.fold(
          (data) async {
            doPostFrame(
              (_) {
                TextInput.finishAutofillContext(shouldSave: true);
              },
            );
            CacheHelper.saveData(key: "user_id", value: data.id);
            emit(LoginSuccess(data));
          },
          (failure) => emit(LoginError(failure)),
        );
      },
      (failure) {
        if (failure is ConnectionFailure || failure is OfflineFailure) {
          emit(LoginError(failure));
        } else {
          emit(LoginError(const Failure("errors.invalid_credentials")));
        }
      },
    );
  }

  Future<void> loginAsGuest() async {
    if (state is LoginLoading) return;

    emit(LoginLoading());

    final deviceId = io_web.deviceID;
    if (deviceId == null) {
      emit(LoginError(const FailedToGetDeviceIdFailure()));
      return;
    }

    final loginResult = await _authRepository.guestLogin(deviceId);

    loginResult.fold(
      (_) async {
        final userResult = await fetchCurrentUser();
        userResult.fold(
          (data) {
            CacheHelper.saveData(key: "user_id", value: data.id);
            emit(LoginSuccess(data));
          },
          (failure) => emit(LoginGuestError(failure)),
        );
      },
      (failure) => emit(LoginGuestError(failure)),
    );
  }

  void togglePasswordVisible() {
    passwordObscure = !passwordObscure;
    emit(LoginChanged());
  }

  void reset() {
    emailController.clear();
    passwordController.clear();
    emit(LoginInitial());
  }

  void updateRememberMe(bool value) {
    rememberMe = value;
    emit(LoginChanged());
  }
}

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final User user;

  LoginSuccess(this.user);
}

class LoginError extends LoginState {
  final Failure failure;

  LoginError(this.failure);
}

class LoginGuestError extends LoginState {
  final Failure failure;

  LoginGuestError(this.failure);
}

class LoginChanged extends LoginState {}

// class LoginState {
//   final User? user;
//   final bool rememberMe;
//   final bool isLoading;
//   final String? error;
//
//   const LoginState({
//     this.user,
//     this.rememberMe = false,
//     this.isLoading = false,
//     this.error,
//   });
//
//   bool get isSuccess => user != null && error == null && !isLoading;
//
//   LoginState copyWith({
//     User? user,
//     bool? rememberMe,
//     bool? isLoading,
//     String? error,
//   }) {
//     return LoginState(
//       user: user ?? this.user,
//       rememberMe: rememberMe ?? this.rememberMe,
//       isLoading: isLoading ?? this.isLoading,
//       error: error,
//     );
//   }
// }
