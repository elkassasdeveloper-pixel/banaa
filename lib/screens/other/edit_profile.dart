import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/utils/validators.dart';
import 'package:educ_student/core/brand_colors.dart';
import 'package:educ_student/screens/other/edit_profile_cubit.dart';
import 'package:educ_student/widgets/banaa_button.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditProfileCubit(),
      child: const _EditProfileView(),
    );
  }
}

class _EditProfileView extends StatelessWidget {
  const _EditProfileView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditProfileCubit>();

    return BlocListener<EditProfileCubit, EditProfileState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == EditProfileStatus.success) {
          context.pop();
        } else if (state.status == EditProfileStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'error'.tr())),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            BlocBuilder<EditProfileCubit, EditProfileState>(
              buildWhen: (previous, current) =>
              previous.status != current.status,
              builder: (context, state) {
                if (state.status == EditProfileStatus.submitting) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                return InkWell(
                  onTap: state.status == EditProfileStatus.ready
                      ? cubit.save
                      : null,
                  child: Text(
                    "save".tr(),
                    style: Omnes.w700.getStyle(
                      fontSize: 18.0,
                      color: BrandColors.primary2,
                    ),
                  ),
                );
              },
            ),
            SizedBox(
              width: 28,
            ),
          ],
          title: Text(
            "profile".tr(),
            style: Omnes.w700.getStyle(
              fontSize: 18.0,
              color: BrandColors.primary2,
            ),
          ),
          leading: Row(
            children: [
              SizedBox(width: 20),
              InkWell(
                onTap: () {
                  context.pop();
                },
                child: Icon(
                  Icons.arrow_back_ios,
                  color: BrandColors.primary2,
                ),
              ),
            ],
          ),
        ),
        body: BlocBuilder<EditProfileCubit, EditProfileState>(
          buildWhen: (previous, current) =>
          previous.status == EditProfileStatus.loading ||
              current.status == EditProfileStatus.loading,
          builder: (context, state) {
            if (state.status == EditProfileStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.user == null) {
              return Center(child: Text(state.errorMessage ?? 'error'.tr()));
            }
            return _EditProfileForm(cubit: cubit);
          },
        ),
      ),
    );
  }
}

class _EditProfileForm extends StatelessWidget {
  const _EditProfileForm({required this.cubit});

  final EditProfileCubit cubit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Divider(
            height: 1,
            color: BrandColors.primary2,
            thickness: .2,
          ),
          SizedBox(
            height: 15,
          ),
          Image.asset("assets/images/change_profile.png"),
          SizedBox(
            height: 8,
          ),
          Text(
            "change_profile".tr(),
            style: Omnes.w700.getStyle(
              fontSize: 18.0,
              color: BrandColors.primary2,
            ),
          ),
          SizedBox(height: 32),
          Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 16),
            child: Form(
                key: cubit.formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "first_name".tr(),
                          style: Omnes.w500.getStyle(
                            color: context.colorScheme.primary,
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: cubit.firstNameController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        labelText: "enter your first name".tr(),
                        labelStyle: const TextStyle(
                          color: Color.fromRGBO(188, 188, 188, 1),
                          fontFamily: "Omnes",
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        alignLabelWithHint: true,
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(width: 1),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: [
                        Text(
                          "last_name".tr(),
                          style: Omnes.w500.getStyle(
                            color: context.colorScheme.primary,
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: cubit.lastNameController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        labelText: "enter your last name".tr(),
                        labelStyle: const TextStyle(
                          color: Color.fromRGBO(188, 188, 188, 1),
                          fontFamily: "Omnes",
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        alignLabelWithHint: true,
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(width: 1),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: [
                        Text(
                          "email".tr(),
                          style: Omnes.w500.getStyle(
                            color: context.colorScheme.primary,
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: cubit.emailController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        labelText: "enter your email".tr(),
                        labelStyle: const TextStyle(
                          color: Color.fromRGBO(188, 188, 188, 1),
                          fontFamily: "Omnes",
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        alignLabelWithHint: true,
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(width: 1),
                        ),
                      ),
                      validator: Validators.emailValidator,
                    ),
                    SizedBox(height: 162),
                    BlocBuilder<EditProfileCubit, EditProfileState>(
                      buildWhen: (previous, current) =>
                      previous.status != current.status,
                      builder: (context, state) {
                        return BanaaButton(
                          onPressed: state.status ==
                              EditProfileStatus.submitting
                              ? null
                              : cubit.save,
                          label: "save".tr(),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                )),
          )
        ],
      ),
    );
  }
}