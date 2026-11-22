import 'package:educ_core/data/models/collection.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/utils/validators.dart';
import 'package:educ_core/widgets/error_message_card.dart';
import 'package:educ_student/core/assets.dart';
import 'package:educ_student/screens/walkthrough/wt_collections_cubit.dart';
import 'package:educ_student/widgets/custom_radio_list_tile.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CollectionSelectForm extends StatelessWidget {
  const CollectionSelectForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WtCollectionsCubit, WtCollectionsState>(
      builder: (context, state) {
        final cubit = context.read<WtCollectionsCubit>();
        return SingleChildScrollView(
          child: Column(
            children: [
              if (state is WtCollectionsError)
                ErrorMessageCard.failure(
                  failure: state.failure,
                  onRetry: () =>
                      cubit.fetchRootCollections(context.locale.languageCode),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Form(
                  key: cubit.formKey,
                  child: FormField<Collection>(
                    initialValue: cubit.selectedCollection,
                    validator: (value) => Validators.requiredField(value),
                    builder: (field) {
                      // final collections = cubit.collections;
                      final filteredCollections = cubit.collections
                          .where((c) => c.himaIsVisable == "Y")
                          .toList();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "what_do_you_want_to_study".tr(),
                            style: Omnes.w400.getStyle(fontSize: 32),
                          ),
                          ErrorMessageCard(title: field.errorText),
                          const SizedBox(height: 16),
                          if (state is WtCollectionsLoading)
                            const CircularProgressIndicator()
                          else if (filteredCollections.isEmpty)
                            Text(
                              "errors.empty_data".tr(),
                              style: Omnes.w400.getStyle(fontSize: 16),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final collection = filteredCollections[index];
                                final isEnabled =
                                    collection.himaIsActive == "Y";
                                return CustomRadioListTile<Collection>(
                                  enabled: isEnabled,
                                  value: collection,
                                  groupValue: cubit.selectedCollection,
                                  onChanged: (value) {
                                    cubit.onCollectionChanged(value);
                                    field.didChange(value);
                                  },
                                  title: Text(collection.name),
                                  leading: SizedBox.square(
                                    dimension: 24,
                                    child: SvgPicture.asset(
                                      Svgs.quranIcon,
                                      colorFilter: context.colorScheme.onSurface
                                          .toColorFilter(),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return const SizedBox(height: 8.0);
                              },
                              itemCount: filteredCollections.length,
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
