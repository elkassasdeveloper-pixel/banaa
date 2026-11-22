import 'dart:ui';

import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_student/core/assets.dart';
import 'package:educ_student/core/routes.dart';
import 'package:educ_student/core/extensions.dart';
import 'package:educ_student/screens/auth/auth_cubit.dart';
import 'package:educ_student/widgets/banaa_button.dart';
import 'package:educ_student/widgets/responsive_layout.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class GuestRestrictedOverlay extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;

  const GuestRestrictedOverlay({
    super.key,
    required this.title,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isGuest = context.user?.isGuest;
        if (isGuest != true) return child;

        return Stack(
          children: [
            FocusScope(
              canRequestFocus: false,
              child: IgnorePointer(child: child),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                child: Container(
                  padding: const EdgeInsets.all(32.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.colorScheme.surface.withValues(alpha: 0.5),
                        context.colorScheme.surface.withValues(alpha: 0.7),
                        context.colorScheme.surface.withValues(alpha: 0.7),
                        context.colorScheme.surface.withValues(alpha: 0.5),
                      ],
                      stops: const [0.0, 0.2, 0.8, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: ResponsiveLayout(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        LottieBuilder.asset(
                          Lotties.shieldAchievement,
                          height: 240,
                          repeat: false,
                        ),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: Omnes.w700.getStyle(
                            fontSize: 24,
                            color: context.colorScheme.tertiary,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          description,
                          textAlign: TextAlign.center,
                          style: Omnes.w500.getStyle(
                            fontSize: 18,
                            color: context.colorScheme.tertiary,
                          ),
                        ),
                        const SizedBox(height: 32.0),
                        BanaaButton.accent(
                          accentColor: context.colorScheme.tertiary,
                          label: "create_account".tr(),
                          onPressed: () {},
                        ),
                        const SizedBox(height: 16.0),
                        TextButton(
                          // accentColor: context.colorScheme.secondary,
                          onPressed: () async {
                            await context
                                .read<AuthCubit>()
                                .signOut(context,showDialog: false)
                                .then((value) {if(context.mounted) context.goNamed(Routes.LOGIN);});
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: context.colorScheme.tertiary,
                          ),
                          // accentColor: context.colorScheme.secondary,
                          child: Text("login".tr()),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
