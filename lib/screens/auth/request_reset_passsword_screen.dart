import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_student/core/brand_colors.dart';
import 'package:educ_student/screens/auth/reset_password_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RequestResetPasswordScreen extends StatelessWidget {
  const RequestResetPasswordScreen({super.key});

  static const String routeName = 'request-reset-password-screen';

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController emailController = TextEditingController();

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: BlocProvider(
        create: (_) => ResetPasswordCubit(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Divider(thickness: 1, color: Color.fromRGBO(230, 233, 244, 1)),
              Container(
                decoration: BoxDecoration(color: context.theme.scaffoldBackgroundColor),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: BlocBuilder<ResetPasswordCubit, PasswordResetState>(
                    builder: (context, state) {
                      final cubit = context.read<ResetPasswordCubit>();
                      return Form(
                        key: formKey,
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            Row(children: [Text("enter email".tr(), style: Omnes.w600.getStyle(fontSize: 16))]),
                            const SizedBox(height: 5),
                            TextFormField(
                              autofocus: true,
                              controller: emailController,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              autofillHints: const [AutofillHints.email],
                              // textDirection: TextDirection.ltr,
                              decoration: InputDecoration(
                                labelText: 'enter your email'.tr(),
                                labelStyle: TextStyle(color: Color.fromRGBO(188, 188, 188, 1), fontFamily: "Omnes", fontSize: 16, fontWeight: FontWeight.w400),
                                alignLabelWithHint: true,
                                suffixIcon: Icon(Icons.email_outlined, color: context.theme.primaryColor),
                                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(width: 1)),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            if (state is RateLimitedState)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  "${"errors.rate_limit_error".tr()} (${state.remainingSeconds}s)",
                                  style: Omnes.w600.getStyle(fontSize: 14, color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            state is LoadingRequestPasswordResetState
                                ? Center(child: SizedBox(child: CircularProgressIndicator(color: context.colorScheme.primary)))
                                : ElevatedButton(
                              onPressed: () {
                                if (!formKey.currentState!.validate()) return;
                                cubit.checkUserAndRequestReset(context, emailController.text.trim());
                              },
                              style: TextButton.styleFrom(foregroundColor: BrandColors.primary1),
                              child: Text("Request Password Reset".tr(), style: Omnes.w600.getStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
