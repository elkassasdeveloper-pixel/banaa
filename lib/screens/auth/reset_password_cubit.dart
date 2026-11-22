import 'package:educ_core/educ_core.dart';
import 'package:educ_core/services/dio_helper.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_student/core/routes.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordCubit extends Cubit<PasswordResetState> {
  ResetPasswordCubit() : super(InitPasswordResetState());

  /*void toggleNewPasswordVisibility() {
    emit({
      'newPasswordVisible': !state['newPasswordVisible']!,
      'confirmPasswordVisible': state['confirmPasswordVisible']!,
    });
  }

  void toggleConfirmPasswordVisibility() {
    emit({
      'newPasswordVisible': state['newPasswordVisible']!,
      'confirmPasswordVisible': !state['confirmPasswordVisible']!,
    });
  }
*/
  final dio = DioHelper.dio;
  bool passwordObscure = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController tokenController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<bool> requestPasswordReset(BuildContext context, String email) async {
    emit(LoadingRequestPasswordResetState());
    try {
      await DioHelper.post(
        successSilent: true,
        showProgressDialog: false,
        context: context,
        endPoint: 'https://banaaapi.hodhdsoft.com/auth/requestPasswordReset',
        queryParameters: {"email": email},
        onError: () {
          emit(ErrorRequestPasswordResetState());
          return false;
        },
        onSuccess: () {
          emit(SuccessRequestPasswordResetState());
          context.goNamed(Routes.RESET_PASSWORD);
        },
      );
      return true;
    } catch (e) {
      emit(ErrorRequestPasswordResetState());
      return false;
    }
  }

  DateTime? _lastResetAttemptTime;
  static const Duration _resetCooldown = Duration(seconds: 30);

  // ResetPasswordCubit
  Future<void> checkUserAndRequestReset(BuildContext context, String email) async {
    if (_lastResetAttemptTime != null) {
      final elapsed = DateTime.now().difference(_lastResetAttemptTime!);
      if (elapsed < _resetCooldown) {
        final remainingSeconds = (_resetCooldown - elapsed).inSeconds;
        emit(RateLimitedState(remainingSeconds: remainingSeconds));
        return;
      }
    }
    _lastResetAttemptTime = DateTime.now();

    emit(LoadingRequestPasswordResetState());
    try {
      final response = await dio.get(
        'https://banaaapi.hodhdsoft.com/auth/user/checkByEmail',
        queryParameters: {"email": email},
      );

      // body is a plain boolean (may arrive as bool or "true"/"false" string)
      final exists = response.data == true || response.data.toString().toLowerCase() == 'true';

      if (!exists) {
        // Prevent email enumeration: respond with generic success and go to reset screen
        if (!context.mounted) return;
        emit(SuccessRequestPasswordResetState());
        context.goNamed(Routes.RESET_PASSWORD);
        return;
      }

      if (!context.mounted) return;
      await requestPasswordReset(context, email);
    } catch (e) {
      emit(ErrorRequestPasswordResetState());
    }
  }

  void togglePasswordVisible() {
    passwordObscure = !passwordObscure;
    emit(PasswordResetChanged());
  }

  Future<void> resetPassword(BuildContext context) async {
    emit(LoadingPasswordResetState());
    try {
      if (formKey.currentState!.validate()) {
        final response = await dio.post('https://banaaapi.hodhdsoft.com/auth/resetPassword', data: {"email": emailController.text, "token": tokenController.text, "newPassword": newPasswordController.text});
        if (response.statusCode == 200) {
          emit(SuccessPasswordResetState());

          if (!context.mounted) return;
          context.showSuccessSnackBar("password_reset_successfully".tr());
          context.goNamed(Routes.LOGIN);
          // return true;
        } else {
          emit(ErrorPasswordResetState());
          // return false;
        }
      }
    } catch (e) {
      emit(ErrorPasswordResetState());
      // return false;
    }
  }
}

abstract class PasswordResetState {}

class InitPasswordResetState extends PasswordResetState {}

class LoadingPasswordResetState extends PasswordResetState {}

class SuccessPasswordResetState extends PasswordResetState {}

class ErrorPasswordResetState extends PasswordResetState {}

class LoadingRequestPasswordResetState extends PasswordResetState {}

class SuccessRequestPasswordResetState extends PasswordResetState {}

class ErrorRequestPasswordResetState extends PasswordResetState {}

class PasswordResetChanged extends PasswordResetState {}

class UserNotFoundState extends PasswordResetState {}

class RateLimitedState extends PasswordResetState {
  final int remainingSeconds;

  RateLimitedState({required this.remainingSeconds});
}
