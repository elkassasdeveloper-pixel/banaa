import 'package:flutter_bloc/flutter_bloc.dart';

class FormCubit extends Cubit<Map<String, bool>> {
  FormCubit()
      : super({
          'passwordVisible': false,
          'newPasswordVisible': false,
          'confirmPasswordVisible': false,
        });

  void togglePasswordVisibility() {
    emit({
      'passwordVisible': !state['passwordVisible']!,
      'newPasswordVisible': state['newPasswordVisible']!,
      'confirmPasswordVisible': state['confirmPasswordVisible']!,
    });
  }

  void toggleNewPasswordVisibility() {
    emit({
      'passwordVisible': state['passwordVisible']!,
      'newPasswordVisible': !state['newPasswordVisible']!,
      'confirmPasswordVisible': state['confirmPasswordVisible']!,
    });
  }

  void toggleConfirmPasswordVisibility() {
    emit({
      'passwordVisible': state['passwordVisible']!,
      'newPasswordVisible': state['newPasswordVisible']!,
      'confirmPasswordVisible': !state['confirmPasswordVisible']!,
    });
  }
}
