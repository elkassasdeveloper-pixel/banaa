import 'package:educ_core/data/models/avatar.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/utils/validators.dart';
import 'package:educ_core/widgets/error_message_card.dart';
import 'package:educ_student/core/brand_colors.dart';
import 'package:educ_student/screens/other/edit_avatar_cubit.dart';
import 'package:educ_student/widgets/avatar_choice.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EditAvatarScreen extends StatelessWidget {
  const EditAvatarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditAvatarCubit()..getAvatars(context),
      child: BlocBuilder<EditAvatarCubit, EditAvatarState>(
        builder: (context, state) {
          final cubit = context.read<EditAvatarCubit>();

          return Scaffold(
            appBar: AppBar(
              actions: [
                InkWell(
                  onTap: () => cubit.save(context),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "save".tr(),
                      style: Omnes.w600.getStyle(
                        fontSize: 18.0,
                        color: BrandColors.primary2,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 28),
              ],
              title: Text(
                "profile_picture".tr(),
                style: Omnes.w500.getStyle(
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
            body: Column(
              children: [
                //   if (state is GetAvatarsErrorState) ErrorMessageCard.failure(failure: state.failure, onRetry: () => cubit.fetchAvatars()),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Form(
                      key: cubit.formKey,
                      child: FormField<Avatar>(
                        initialValue: cubit.selectedAvatar,
                        validator: (value) =>
                            Validators.requiredField(value?.id),
                        builder: (field) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "select_profile_picture".tr(),
                                style: Omnes.w400.getStyle(fontSize: 24),
                              ),
                              ErrorMessageCard(title: field.errorText),
                              const SizedBox(height: 16),
                              if (state is GetAvatarsLoadingState)
                                Center(child: const CircularProgressIndicator())
                              else if (cubit.avatars.isEmpty)
                                Text(
                                  "errors.empty_data".tr(),
                                  style: Omnes.w400.getStyle(fontSize: 16),
                                )
                              else
                                Expanded(
                                  child: GridView.builder(
                                    scrollCacheExtent: const ScrollCacheExtent.pixels(100000),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          childAspectRatio: 1,
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 8,
                                          mainAxisSpacing: 8,
                                        ),
                                    itemCount: cubit.avatars.length,
                                    itemBuilder: (context, index) {
                                      final avatar = cubit.avatars[index];
                                      return AvatarChoice(
                                        url: avatar.fileName,
                                        onSelected: () {
                                          cubit.onAvatarChanged(
                                            context,
                                            avatar,
                                          );
                                          field.didChange(avatar);
                                        },
                                        isSelected:
                                            cubit.selectedAvatar ==
                                            avatar,
                                      );
                                    },
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
