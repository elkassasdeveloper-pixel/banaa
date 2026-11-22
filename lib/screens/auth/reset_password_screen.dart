import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/logger.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/utils/validators.dart';
import 'package:educ_student/screens/auth/reset_password_cubit.dart';
import 'package:educ_student/widgets/banaa_button.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  static const String routeName = 'reset-password-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Divider(thickness: 1, color: Color.fromRGBO(230, 233, 244, 1)),
            Container(
              decoration: BoxDecoration(color: context.theme.scaffoldBackgroundColor),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BlocProvider(
                  create: (_) => ResetPasswordCubit(),
                  child: BlocBuilder<ResetPasswordCubit, PasswordResetState>(
                    builder: (context, state) {
                      final cubit = context.read<ResetPasswordCubit>();

                      return Form(
                        key: cubit.formKey,
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            Row(children: [Text("email".tr(), style: Omnes.w600.getStyle(fontSize: 16))]),
                            const SizedBox(height: 5),
                            TextFormField(
                              controller: cubit.emailController,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              autofillHints: const [AutofillHints.email],
                              decoration: InputDecoration(
                                alignLabelWithHint: true,
                                suffixIcon: Icon(Icons.email_outlined, color: context.theme.primaryColor),
                                border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(width: 1)),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.emailValidator,
                              textAlign: TextAlign.left,
                              textDirection: TextDirection.ltr,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 20),
                            Row(children: [Text("new_password".tr(), style: Omnes.w600.getStyle(fontSize: 16))]),
                            const SizedBox(height: 5),
                            TextFormField(
                              controller: cubit.newPasswordController,
                              obscureText: cubit.passwordObscure /*!state['newPasswordVisible']!*/,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              // autofillHints: const [AutofillHints.password],
                              decoration: InputDecoration(
                                suffixIcon: IconButton(icon: Icon(cubit.passwordObscure ? Icons.visibility : Icons.visibility_off), onPressed: cubit.togglePasswordVisible),
                              ),
                              validator: Validators.passwordValidator,
                              textAlign: TextAlign.left,
                              textDirection: TextDirection.ltr,
                            ),
                            const SizedBox(height: 12),
                            Row(children: [Text("confirm_password".tr(), style: Omnes.w600.getStyle(fontSize: 16))]),
                            const SizedBox(height: 5),
                            TextFormField(
                              controller: cubit.confirmPasswordController,
                              obscureText: cubit.passwordObscure,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              // autofillHints: const [AutofillHints.password],
                              textDirection: TextDirection.ltr,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(icon: Icon(cubit.passwordObscure ? Icons.visibility : Icons.visibility_off), onPressed: cubit.togglePasswordVisible),
                              ),
                              validator: (value) => Validators.passwordMatchValidator(cubit.newPasswordController.text, value),
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 12),
                            Row(children: [Text("OTP", style: Omnes.w600.getStyle(fontSize: 16))]),
                            const SizedBox(height: 5),
                            TextFormField(
                              controller: cubit.tokenController,
                              // obscureText: !state['confirmPasswordVisible']!,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              // autofillHints: const [AutofillHints.password],
                              textDirection: TextDirection.ltr,

                              validator: Validators.requiredField,
                            ),
                            const SizedBox(height: 48),
                            state is LoadingPasswordResetState
                                ? Center(
                                    child: SizedBox(child: CircularProgressIndicator(color: context.colorScheme.primary)),
                                  )
                                : BanaaButton.accent(
                                    accentColor: context.colorScheme.primary,
                                    isEnabled: state is! LoadingPasswordResetState,
                                    label: "reset_password".tr(),
                                    onPressed: () {
                                      Logger.Green("reset password");
                                      cubit.resetPassword(context);
                                    },
                                  ),
                            /*ElevatedButton(
                              onPressed: () => cubit.resetPassword(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromRGBO(
                                  84,
                                  90,
                                  146,
                                  1,
                                ),
                                side: const BorderSide(
                                  color: Color.fromRGBO(84, 90, 146, 1),
                                  width: 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'reset_password'.tr(),
                                style: const TextStyle(
                                  color: Color.fromRGBO(188, 188, 188, 1),
                                  fontFamily: "Omnes",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),*/
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
