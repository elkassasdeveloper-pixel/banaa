import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_student/screens/auth/change_password_cubit.dart';
import 'package:educ_student/widgets/banaa_button.dart';
import 'package:educ_student/widgets/responsive_layout.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  static const String routeName = 'change-passwod-screen';

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenHeightRatio = screenHeight / 822; // 822 refers to the design height
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(backgroundColor:  context.theme.scaffoldBackgroundColor, leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios))),
      body: ResponsiveLayout(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Divider(
                thickness: 1,
                // color: Color.fromRGBO(230, 233, 244, 1),
                  color: context.theme.scaffoldBackgroundColor
              ),
              Container(
                // decoration: const BoxDecoration(color: Color.fromRGBO(240, 252, 255, 1)),
                decoration:   BoxDecoration(color: context.theme.scaffoldBackgroundColor),

                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AutofillGroup(
                    child: BlocProvider(
                      create: (_) => FormCubit(),
                      child: BlocBuilder<FormCubit, Map<String, bool>>(
                        builder: (context, state) {
                          return Form(
                            key: formKey,
                            child: Column(
                              children: [
                                const SizedBox(height: 24),
                                  Row(
                                  children: [
                                    Text(
                                      "old password".tr(),
                                      style: Omnes.w500.getStyle(
                                        color: context.colorScheme.primary,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                TextFormField(
                                  // autofocus: true,
        
                                  controller: passwordController,
                                  obscureText: !state['passwordVisible']!,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  autofillHints: const [AutofillHints.password],
                                  // textDirection: TextDirection.ltr,
                                  decoration: InputDecoration(
                                    labelText: "enter your password".tr(),
                                    labelStyle: const TextStyle(
                                      color: Color.fromRGBO(188, 188, 188, 1),
                                      fontFamily: "Omnes",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    alignLabelWithHint: true,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        state['passwordVisible']! ? Icons.visibility : Icons.visibility_off,
                                        color: const Color.fromRGBO(31, 31, 31, 1),
                                      ),
                                      onPressed: () {
                                        context.read<FormCubit>().togglePasswordVisibility();
                                      },
                                    ),
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                      borderSide: BorderSide(width: 1),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                  Row(
                                  children: [
                                    Text(
                                      "new password".tr(),
                                      style: Omnes.w500.getStyle(
                                        color: context.colorScheme.primary,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                TextFormField(
                                  // autofocus: true,
                                  controller: newPasswordController,
                                  obscureText: !state['newPasswordVisible']!,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  autofillHints: const [AutofillHints.password],
                                  // // textDirection: TextDirection.ltr,
                                  decoration: InputDecoration(
                                    labelText: "enter your password".tr(),
                                    labelStyle: const TextStyle(
                                      color: Color.fromRGBO(188, 188, 188, 1),
                                      fontFamily: "Omnes",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    alignLabelWithHint: true,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        state['newPasswordVisible']! ? Icons.visibility : Icons.visibility_off,
                                        color: const Color.fromRGBO(31, 31, 31, 1),
                                      ),
                                      onPressed: () {
                                        context.read<FormCubit>().toggleNewPasswordVisibility();
                                      },
                                    ),
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                      borderSide: BorderSide(width: 1),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your new password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                  Row(
                                  children: [
                                    Text(
                                      "confirm new password".tr(),
                                      style: Omnes.w500.getStyle(
                                        color: context.colorScheme.primary,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                TextFormField(
                                  // autofocus: true,
                                  controller: confirmPasswordController,
                                  obscureText: !state['confirmPasswordVisible']!,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  autofillHints: const [AutofillHints.password],
                                  // textDirection: TextDirection.ltr,
                                  decoration: InputDecoration(
                                    labelText: "enter your password".tr(),
                                    labelStyle: const TextStyle(
                                      color: Color.fromRGBO(188, 188, 188, 1),
                                      fontFamily: "Omnes",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    alignLabelWithHint: true,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        state['confirmPasswordVisible']! ? Icons.visibility : Icons.visibility_off,
                                        color: const Color.fromRGBO(31, 31, 31, 1),
                                      ),
                                      onPressed: () {
                                        context.read<FormCubit>().toggleConfirmPasswordVisibility();
                                      },
                                    ),
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                      borderSide: BorderSide(width: 1),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please confirm your password';
                                    }
                                    if (value != newPasswordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                                // Spacer when keyboard is visible
                                SizedBox(
                                  height: MediaQuery.viewInsetsOf(context).bottom > 0.0
                                      ? 100 * screenHeightRatio
                                      : 310 * screenHeightRatio,
                                ),
                                /*      if (state['bottomButton']!)*/
                                BanaaButton(
                                  label: "confirm".tr(),
                                  // onPressed: cubit.login,
                                ),
                              /*  FilledButton(
                                  onPressed: () {},
                                  style: FilledButton.styleFrom(
                                    minimumSize: Size(358 * screenWidthRatio, 56),
                                    backgroundColor: Colors.transparent,
                                    side: BorderSide(
                                      color: Color.fromRGBO(0, 86, 128, 1),
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8), // Add border radius here
                                    ),
                                  ),
                                  child: const Text(
                                    "confirm",
                                    style: TextStyle(
                                      color: Color.fromRGBO(0, 86, 128, 1),
                                      fontFamily: "Omnes",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.1,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
