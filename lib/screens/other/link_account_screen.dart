import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/utils/validators.dart';
import 'package:educ_student/core/assets.dart';
import 'package:educ_student/core/brand_colors.dart';
import 'package:educ_student/screens/auth/link_account_cubit.dart';
import 'package:educ_student/widgets/banaa_button.dart';
import 'package:educ_student/widgets/responsive_layout.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LinkAccountScreen extends StatelessWidget {
  const LinkAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LinkAccountCubit(),
      child: BlocBuilder<LinkAccountCubit, LinkAccountState>(
        builder: (context, state) {
          final cubit = context.read<LinkAccountCubit>();
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              automaticallyImplyLeading: false,
              // title: Hero(
              //   tag: Strings.logoHeroTag,
              //   child: SvgPicture.asset(
              //     Svgs.banaaLogoWithText,
              //     width: 46,
              //     height: 30,
              //   ),
              // ),
           //   title: Icon(Icons.link_rounded, color: BrandColors.primary2),
              title: PreferredSize(
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
                          "link_account".tr(),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 22, vertical: 16),
                child: AutofillGroup(
                  key: cubit.autofillGroupKey,
                  child: Form(
                    key: cubit.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // if (state is SignUpError) ...[
                        //   ErrorMessageCard.failure(
                        //     failure: state.failure,
                        //   ),
                        //   const SizedBox(height: 16),
                        // ],
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
                          validator: (value) =>
                              Validators.passwordMatchValidator(
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
                          // onEditingComplete: () =>
                          //     _goToWalkthrough(context, cubit),
                        ),
                        const SizedBox(height: 24),
                        if (state is LinkAccountLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          BanaaButton(
                            label: "link_account".tr(),
                            onPressed: () => cubit.linkAccount(context),
                          ),

                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
