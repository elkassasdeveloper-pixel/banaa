import 'package:educ_core/constants/enums.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/utils/validators.dart';
import 'package:educ_core/widgets/error_message_card.dart';
import 'package:educ_student/core/assets.dart';
import 'package:educ_student/screens/auth/sign_up_cubit.dart';
import 'package:educ_student/screens/walkthrough/walkthrough_cubit.dart';
import 'package:educ_student/widgets/custom_radio_list_tile.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LevelSelectForm extends StatelessWidget {
  const LevelSelectForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      builder: (context, signUpState) {
        final signupCubit = context.read<SignUpCubit>();

        return BlocBuilder<WalkthroughCubit, WalkthroughState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: signupCubit.knowledgeLevelFormKey,
                child: FormField<AccountKnowledgeLevel>(
                    initialValue: signupCubit.knowledgeLevel,
                    validator: (value) => Validators.requiredField(value),
                    builder: (field) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "what_is_your_current_level".tr(),
                            style: Omnes.w400.getStyle(fontSize: 32),
                          ),
                          ErrorMessageCard(title: field.errorText),
                          const SizedBox(height: 16),
                          CustomRadioListTile<AccountKnowledgeLevel>(
                            value: AccountKnowledgeLevel.beginner,
                            groupValue: signupCubit.knowledgeLevel,
                            onChanged: (value) {
                              signupCubit.onKnowledgeLevelChanged(value);
                              field.didChange(value);
                            },
                            title: Text("beginner".tr()),
                            leading: SizedBox.square(
                              dimension: 24,
                              child: SvgPicture.asset(
                                Svgs.quranIcon,
                                colorFilter: context.colorScheme.onSurface
                                    .toColorFilter(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomRadioListTile<AccountKnowledgeLevel>(
                            value: AccountKnowledgeLevel.advanced,
                            groupValue: signupCubit.knowledgeLevel,
                            onChanged: (value) {
                              signupCubit.onKnowledgeLevelChanged(value);
                              field.didChange(value);
                            },
                            title: Text("advanced".tr()),
                            leading: SizedBox.square(
                              dimension: 24,
                              child: SvgPicture.asset(
                                Svgs.quranIcon,
                                colorFilter: context.colorScheme.onSurface
                                    .toColorFilter(),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
              ),
            );
          },
        );
      },
    );
  }
}
