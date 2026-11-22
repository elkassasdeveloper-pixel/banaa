import 'package:educ_core/constants/enums.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_student/core/assets.dart';
import 'package:educ_student/core/routes.dart';
import 'package:educ_student/core/brand_colors.dart';
import 'package:educ_student/core/helpers.dart';
import 'package:educ_student/screens/auth/sign_up_cubit.dart';
import 'package:educ_student/screens/walkthrough/wt_avatars_cubit.dart';
import 'package:educ_student/screens/walkthrough/wt_collections_cubit.dart';
import 'package:educ_student/screens/walkthrough/wt_user_details_form_cubit.dart';
import 'package:educ_student/screens/walkthrough/walkthrough_cubit.dart';
import 'package:educ_student/screens/walkthrough/avatar_select_form.dart';
import 'package:educ_student/screens/walkthrough/collection_select_form.dart';
import 'package:educ_student/screens/walkthrough/level_select_form.dart';
import 'package:educ_student/screens/walkthrough/user_details_form.dart';
import 'package:educ_student/widgets/banaa_button.dart';
import 'package:educ_student/widgets/page_indicator.dart';
import 'package:educ_student/widgets/responsive_layout.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class WalkthroughScreen extends StatelessWidget {
  const WalkthroughScreen({
    super.key,
  });

  bool canPop(WalkthroughCubit cubit) => cubit.currentIndex == 0;

  @override
  Widget build(BuildContext context) {
    const views = [
      UserDetailsForm(),
      AvatarSelectForm(),
      CollectionSelectForm(),
      LevelSelectForm(),
    ];

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => WalkthroughCubit(),
        ),
        BlocProvider(
          create: (_) => WtUserDetailsFormCubit()..fetchAllCountries(),
          lazy: false,
        ),
        BlocProvider(
          create: (_) => WtAvatarsCubit()..fetchAvatars(),
          lazy: false,
        ),
        BlocProvider(
          create: (_) => WtCollectionsCubit()
            ..fetchRootCollections(context.locale.languageCode),
          lazy: false,
        ),
      ],
      child: BlocListener<SignUpCubit, SignUpState>(
        listener: (context, state) async {
          if (state is SignUpSuccess) {
            onAuthenticated(context, state.user);
          }

          if (state is SignUpError) {
            context.showFailureSnackBar(state.failure);
          }
        },
        child: BlocBuilder<WalkthroughCubit, WalkthroughState>(
          builder: (context, state) {
            final cubit = context.read<WalkthroughCubit>();

            return PopScope(
              canPop: canPop(cubit),
              onPopInvokedWithResult: (didPop,result) {
                if (!didPop) {
                  cubit.goPreviousView();
                }
              },
              child: Scaffold(
                body: SafeArea(
                  child: ResponsiveLayout(
                    child: Column(
                      children: [
                        SizedBox(
                          height: kToolbarHeight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.only(start: 22),
                                child: SizedBox.square(
                                  dimension: 32,
                                  child: IconButton.filled(
                                    onPressed: () =>
                                        _goBack(context, canPop(cubit)),
                                    icon: SvgPicture.asset(
                                      Svgs.arrowLeft,
                                      width: 20,
                                      height: 20,
                                      colorFilter:
                                          BrandColors.primary2.toColorFilter(),
                                      matchTextDirection: true,
                                    ),
                                    style: IconButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      backgroundColor: BrandColors.primary3,
                                      shape: const CircleBorder(),
                                    ),
                                  ),
                                ),
                              ),
                              PageIndicator(
                                currentIndex: cubit.currentIndex,
                                pagesCount: views.length,
                              ),
                              const SizedBox(width: 56),
                            ],
                          ),
                        ),
                        Expanded(
                          child: PageView(
                            controller: cubit.pageController,
                            onPageChanged: cubit.onPageChanged,
                            physics: const NeverScrollableScrollPhysics(),
                            children: views,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          child: _buildNextButton(state, views.length, cubit),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // void _onCountriesLoaded(WtUserDetailsFormCubit cubit) {}
  //
  // void _onAvatarsLoaded(WtAvatarsCubit cubit) {
  //   final avatars = cubit.avatars;
  //   if (avatars.isNotEmpty) {
  //     cubit.onAvatarChanged(avatars.first);
  //   }
  // }
  //
  // void _onCollectionsLoaded(WtCollectionsCubit cubit) {
  //   final collections = cubit.collections;
  //   if (collections.isNotEmpty) {
  //     cubit.onCollectionChanged(collections.first);
  //   }
  // }

  BlocBuilder<SignUpCubit, SignUpState> _buildNextButton(
    WalkthroughState state,
    int viewsLength,
    WalkthroughCubit cubit,
  ) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      builder: (context, signUpState) {
        final signUpCubit = context.read<SignUpCubit>();

        if (signUpState is SignUpLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final String label;

        if (cubit.currentIndex == viewsLength - 1) {
          if (signUpCubit.knowledgeLevel == AccountKnowledgeLevel.advanced) {
            label = "test_your_level".tr();
          } else {
            label = "start_learning".tr();
          }
        } else {
          label = "continue".tr();
        }

        return BanaaButton(
          label: label,
          onPressed: () {
            final userDetailsCubit = context.read<WtUserDetailsFormCubit>();
            final avatarsCubit = context.read<WtAvatarsCubit>();
            final collectionsCubit = context.read<WtCollectionsCubit>();

            if (cubit.currentIndex < viewsLength - 1) {
              FocusManager.instance.primaryFocus?.unfocus();
              bool isValid = cubit.validateForms(
                userDetailsCubit.formKey,
                avatarsCubit.formKey,
                collectionsCubit.formKey,
                signUpCubit.knowledgeLevelFormKey,
              );
              if (isValid) cubit.goNextView();
            } else {
              if (signUpCubit.knowledgeLevel ==
                  AccountKnowledgeLevel.advanced) {
                if (collectionsCubit.selectedCollection == null) {
                  context
                      .showErrorSnackBar("errors.collection_is_required".tr());
                } else {
                  context.pushNamed(
                    Routes.ADVANCED_QUIZ,
                    queryParameters: {
                      "rootCollectionId":
                          collectionsCubit.selectedCollection?.id,
                      "languageCode": context.locale.languageCode.toLowerCase(),
                    },
                    extra: () => signUp(context),
                  );
                }
              } else {
                signUp(context);
              }
            }
          },
        );
      },
    );
  }

  static Future<void> signUp(BuildContext context) async {
    final signUpCubit = context.read<SignUpCubit>();
    final avatarsCubit = context.read<WtAvatarsCubit>();
    final collectionsCubit = context.read<WtCollectionsCubit>();
    final userDetailsFormCubit = context.read<WtUserDetailsFormCubit>();

    await signUpCubit.signUp(
      firstName: userDetailsFormCubit.firstNameController.text,
      lastName: userDetailsFormCubit.lastNameController.text,
      gender: userDetailsFormCubit.gender,
      age: int.tryParse(userDetailsFormCubit.ageController.text) ?? 8,
      avatarId: avatarsCubit.selectedAvatar?.id ?? 1,
      countryCode: userDetailsFormCubit.selectedCountry?.code ?? "SAU",
      rootCollectionId: collectionsCubit.selectedCollection?.id ?? "2",
      languageCode: context.locale.languageCode,
    );
  }

  void _goBack(BuildContext context, bool canPop) {
    if (canPop) {
      context.pop();
    } else {
      context.read<WalkthroughCubit>().goPreviousView();
    }
  }
}
