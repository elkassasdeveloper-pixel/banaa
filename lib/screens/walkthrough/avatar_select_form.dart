import 'package:educ_core/data/models/avatar.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/utils/validators.dart';
import 'package:educ_core/widgets/error_message_card.dart';
import 'package:educ_student/screens/walkthrough/wt_avatars_cubit.dart';
import 'package:educ_student/widgets/avatar_choice.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AvatarSelectForm extends StatelessWidget {
  const AvatarSelectForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WtAvatarsCubit, WtAvatarsState>(
      builder: (context, state) {
        final cubit = context.read<WtAvatarsCubit>();
        return Column(
          children: [
            if (state is WtAvatarsError) ErrorMessageCard.failure(failure: state.failure, onRetry: () => cubit.fetchAvatars()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Form(
                  key: cubit.formKey,
                  child: FormField<Avatar>(
                    initialValue: cubit.selectedAvatar,
                    validator: (value) => Validators.requiredField(value?.id),
                    builder: (field) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("select_profile_picture".tr(), style: Omnes.w400.getStyle(fontSize: 32)),
                          ErrorMessageCard(title: field.errorText),
                          const SizedBox(height: 16),
                          if (state is WtAvatarsLoading)
                            const CircularProgressIndicator()
                          else if (cubit.avatars.isEmpty)
                            Text("errors.empty_data".tr(), style: Omnes.w400.getStyle(fontSize: 16))
                          else
                            Expanded(
                              child: GridView.builder(
                                shrinkWrap: true,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(childAspectRatio: 1, crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                                itemCount: cubit.avatars.length,
                                itemBuilder: (context, index) {
                                  final avatar = cubit.avatars[index];
                                  return AvatarChoice(
                                    url: avatar.fileName,
                                    onSelected: () {
                                      cubit.onAvatarChanged(avatar);
                                      field.didChange(avatar);
                                    },
                                    isSelected: cubit.selectedAvatar == avatar,
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
        );
      },
    );
  }
}
