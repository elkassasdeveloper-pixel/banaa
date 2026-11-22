import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/utils/validators.dart';
import 'package:educ_core/widgets/error_message_card.dart';
import 'package:educ_student/core/assets.dart';
import 'package:educ_student/core/constants.dart';
import 'package:educ_student/core/routes.dart';
import 'package:educ_student/core/brand_colors.dart';
import 'package:educ_student/screens/auth/sign_up_cubit.dart';
import 'package:educ_student/widgets/banaa_button.dart';
import 'package:educ_student/widgets/responsive_layout.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      builder: (context, state) {
        final cubit = context.read<SignUpCubit>();

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: Hero(
              tag: Strings.logoHeroTag,
              child: SvgPicture.asset(
                Svgs.banaaLogoWithText,
                width: 46,
                height: 30,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: ResponsiveLayout(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 32,
                        child: IconButton.filled(
                          onPressed: context.pop,
                          icon: SvgPicture.asset(
                            Svgs.arrowLeft,
                            width: 20,
                            height: 20,
                            colorFilter: BrandColors.primary2.toColorFilter(),
                            matchTextDirection: true,
                          ),
                          style: IconButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: BrandColors.primary3,
                            shape: const CircleBorder(),
                          ),
                        ),
                      ),
                      Text(
                        "create_new_account".tr(),
                        style: Omnes.w700.getStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(width: 32)
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: ResponsiveLayout(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              child: AutofillGroup(
                key: cubit.autofillGroupKey,
                child: Form(
                  key: cubit.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (state is SignUpError) ...[
                        ErrorMessageCard.failure(
                          failure: state.failure,
                        ),
                        const SizedBox(height: 16),
                      ],
                      Text(
                        "email".tr(),
                        style: Omnes.w400.getStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        // autofocus: true,
                        controller: cubit.emailController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [
                          AutofillHints.username,
                          AutofillHints.email,
                        ],
                        validator: Validators.emailValidator,
                        textAlign: TextAlign.left,
                        textDirection: TextDirection.ltr,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "password".tr(),
                        style: Omnes.w400.getStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: cubit.passwordController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        keyboardType: TextInputType.visiblePassword,
                        autofillHints: const [AutofillHints.newPassword],
                        obscureText: cubit.passwordObscure,
                        validator: Validators.passwordValidator,
                        textAlign: TextAlign.left,
                        textDirection: TextDirection.ltr,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(
                              cubit.passwordObscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: cubit.togglePasswordVisible,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "confirm_password".tr(),
                        style: Omnes.w400.getStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: cubit.confirmPasswordController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        keyboardType: TextInputType.visiblePassword,
                        autofillHints: const [AutofillHints.newPassword],
                        obscureText: cubit.passwordObscure,
                        validator: (value) => Validators.passwordMatchValidator(
                            cubit.passwordController.text, value),
                        textAlign: TextAlign.left,
                        textDirection: TextDirection.ltr,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(
                              cubit.passwordObscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: cubit.togglePasswordVisible,
                          ),
                        ),
                        onEditingComplete: () =>
                            _goToWalkthrough(context, cubit),
                      ),
                      const SizedBox(height: 24),
                      if (state is SignUpLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        BanaaButton(
                          label: "create_new_account".tr(),
                          onPressed: () => _goToWalkthrough(context, cubit),
                        ),
                      const SizedBox(height: 40),
                      Wrap(
                        alignment: WrapAlignment.center,
                        runAlignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Text(
                            "do_you_have_account".tr(),
                            textAlign: TextAlign.center,
                            style: Omnes.w600.getStyle(fontSize: 16),
                          ),
                          TextButton(
                            onPressed: () {
                              context.pushReplacementNamed(Routes.LOGIN);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: BrandColors.primary1,
                            ),
                            child: Text(
                              "login".tr(),
                              textAlign: TextAlign.center,
                              style: Omnes.w600.getStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _goToWalkthrough(BuildContext context, SignUpCubit cubit) async {
    if (cubit.formKey.currentState?.validate() == true) {
      await cubit.isEmailExist().then(
        (value) {
          if (value == false) {
           if(context.mounted) context.pushNamed(Routes.WALKTHROUGH);
          } else {
            return;
          }
        },
      );
    }
  }
}
