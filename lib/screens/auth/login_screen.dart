import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/utils/validators.dart';
import 'package:educ_core/widgets/error_message_card.dart';
import 'package:educ_student/core/assets.dart';
import 'package:educ_student/core/constants.dart';
import 'package:educ_student/core/routes.dart';
import 'package:educ_student/core/brand_colors.dart';
import 'package:educ_student/core/helpers.dart';
import 'package:educ_student/screens/auth/login_cubit.dart';
import 'package:educ_student/widgets/banaa_button.dart';
import 'package:educ_student/widgets/responsive_layout.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          onAuthenticated(context, state.user);
        }
      },
      builder: (context, state) {
        final cubit = context.read<LoginCubit>();
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
                      Expanded(
                        child: Text(
                          "login".tr(),
                          style: Omnes.w700.getStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
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
                onDisposeAction: AutofillContextAction.commit,
                child: Form(
                  key: cubit.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (state is LoginError) ...[
                        ErrorMessageCard.failure(
                          failure: state.failure,
                          showDescription: false,

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
                        autofillHints: const [AutofillHints.password],
                        obscureText: cubit.passwordObscure,
                        validator: Validators.passwordValidator,
                        textAlign: TextAlign.left,
                        textDirection: TextDirection.ltr,
                        textInputAction: TextInputAction.done,
                        onEditingComplete: cubit.login,
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
                      const SizedBox(height: 24),
                      if (state is LoginLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        BanaaButton(
                          label: "login".tr(),
                          onPressed: cubit.login,
                        ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () =>
                            context.pushNamed(Routes.REQUEST_PASSWORD_RESET),
                        style: TextButton.styleFrom(
                          foregroundColor: BrandColors.secondary1,
                        ),
                        child: Text(
                          "forgot_password".tr(),
                          textAlign: TextAlign.center,
                        ),
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
                            "dont_have_account".tr(),
                            textAlign: TextAlign.center,
                            style: Omnes.w600.getStyle(fontSize: 16),
                          ),
                          TextButton(
                            onPressed: () {
                              context.pushReplacementNamed(Routes.SIGN_UP);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: BrandColors.primary1,
                            ),
                            child: Text(
                              "create_new_account".tr(),
                              textAlign: TextAlign.center,
                              style: Omnes.w600.getStyle(fontSize: 16),
                            ),
                          )
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
}
