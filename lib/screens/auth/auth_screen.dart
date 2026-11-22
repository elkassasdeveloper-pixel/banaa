import 'package:educ_core/educ_core.dart';
import 'package:educ_core/error/failures.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/logger.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_student/core/assets.dart';
import 'package:educ_student/core/brand_colors.dart';
import 'package:educ_student/core/constants.dart';
import 'package:educ_student/core/extensions.dart';
import 'package:educ_student/core/helpers.dart';
import 'package:educ_student/core/routes.dart';
import 'package:educ_student/screens/auth/login_cubit.dart';
import 'package:educ_student/screens/auth/sign_up_cubit.dart';
import 'package:educ_student/widgets/banaa_button.dart';
import 'package:educ_student/widgets/responsive_layout.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          onAuthenticated(context, state.user);
          Strings.userId = state.user.id;
          debugPrint(">>>>>+${Strings.userId}");
        } else if (state is LoginGuestError) {
          if (state.failure is! OfflineFailure) {
            final statusCode = state.failure.response?.statusCode;
            final isNotFound = statusCode == 404;
            Logger.data("Guest Error", statusCode);

            if (isNotFound) {
              context.read<SignUpCubit>().setIsGuest(true);
              context.pushNamed(Routes.WALKTHROUGH);
              return;
            }
          }
          context.showFailureSnackBar(state.failure);
        }
      },
      builder: (context, state) {
        final cubit = context.read<LoginCubit>();
        final isLoading = state is LoginLoading;
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ResponsiveLayout(
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Hero(
                        tag: Strings.logoHeroTag,
                        child: SvgPicture.asset(
                          Svgs.banaaLogoWithText,
                          height: 56,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Stack(
                        children: [
                          Center(
                            child: SvgPicture.asset(
                              Svgs.circlePattern,
                              width: 340,
                              height: 340,
                              colorFilter:
                                  BrandColors.primary3.withValues(alpha: context.isDark ? 0.12 : 0.6).toColorFilter(),
                            ),
                          ),
                          Center(
                            child: Image.asset(
                              Images.earth,
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    BanaaButton(
                      isEnabled: !isLoading,
                      label: "create_account".tr(),
                      onPressed: () => context.pushNamed(Routes.SIGN_UP),
                    ),
                    const SizedBox(height: 16),
                    BanaaButton.accentSurface(
                      accentColor: context.colorScheme.primary,
                      backgroundColor: context.colorScheme.primaryContainer,
                      isEnabled: !isLoading,
                      label: "already_have_account".tr(),
                      onPressed: () => context.pushNamed(Routes.LOGIN),
                    ),
                    const SizedBox(height: 8),
                    _buildLoginAsGuestButton(cubit, context),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginAsGuestButton(LoginCubit cubit, BuildContext context) {
    if (cubit.state is LoginLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return TextButton(
      onPressed: () => cubit.loginAsGuest(),
      style: TextButton.styleFrom(
        foregroundColor: BrandColors.secondary1,
      ),
      child: Text(
        "continue_as_guest".tr(),
        style: Omnes.w700.getStyle(fontSize: 16, color: BrandColors.secondary1).apply(
              decoration: TextDecoration.underline,
              decorationColor: BrandColors.secondary1,
            ),
      ),
    );
  }
}
