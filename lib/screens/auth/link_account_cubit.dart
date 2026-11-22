import 'package:educ_core/data/models/user.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/services/dio_helper.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/helpers.dart';
import 'package:educ_core/utils/result.dart';
import 'package:educ_student/core/helpers.dart';
import 'package:educ_student/core/routes.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LinkAccountCubit extends Cubit<LinkAccountState> {
  LinkAccountCubit() : super(LinkAccountInitial());

  final formKey = GlobalKey<FormState>();
  final autofillGroupKey = GlobalKey<AutofillGroupState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool passwordObscure = true;
  final dio = DioHelper.dio;

  Future<void> linkAccount(BuildContext context) async {
    emit(LinkAccountLoading());
    final response = await dio.post(
      '/auth/guest/toUser',
      data: {
        "email": emailController.text,
        "password": passwordController.text,
      },
    );
    final data = response.data;

    final token = data['token'];
    DioHelper.setToken(token);
    DioHelper.init();
    await Future.delayed(const Duration(seconds: 1));
    final userResult = await fetchCurrentUser();
    userResult.fold((data) async {
      doPostFrame((_) {
        TextInput.finishAutofillContext(shouldSave: true);
      });
      emit(LinkAccountSuccess(data));
      context.showSuccessSnackBar("account_linked_successfully".tr());
      context.pushNamed(Routes.LEARN);
    }, (failure) => emit(LinkAccountError(failure)));
  }

  void togglePasswordVisible() {
    passwordObscure = !passwordObscure;
    emit(LinkAccountChanged());
  }
}

class LinkAccountState {}

class LinkAccountInitial extends LinkAccountState {}

class LinkAccountLoading extends LinkAccountState {}

class LinkAccountSuccess extends LinkAccountState {
  final User user;

  LinkAccountSuccess(this.user);
}

class LinkAccountError extends LinkAccountState {
  final Failure failure;

  LinkAccountError(this.failure);
}

class LinkAccountChanged extends LinkAccountState {}
