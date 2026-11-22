import 'package:educ_core/constants/enums.dart';
import 'package:educ_core/data/models/country.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/utils/validators.dart';
import 'package:educ_core/widgets/error_message_card.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
import 'package:educ_student/core/extensions.dart';
import 'package:educ_student/screens/walkthrough/wt_avatars_cubit.dart';
import 'package:educ_student/screens/walkthrough/wt_user_details_form_cubit.dart';
import 'package:educ_student/widgets/custom_radio_list_tile.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserDetailsForm extends StatelessWidget {
  const UserDetailsForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WtUserDetailsFormCubit, WtUserFormState>(
      builder: (context, state) {
        final cubit = context.read<WtUserDetailsFormCubit>();
        return Column(
          children: [
            if (state is WtUserFormError)
              ErrorMessageCard.failure(
                failure: state.failure,
                onRetry: cubit.fetchAllCountries,
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Form(
                  key: cubit.formKey,
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "fill_your_details".tr(),
                          style: Omnes.w400.getStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "your_gender".tr(),
                          style: Omnes.w400.getStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        _buildGenderOptions(context, cubit),
                        const SizedBox(height: 24),
                        Text(
                          "what_is_your_name".tr(),
                          style: Omnes.w400.getStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        _buildNameFields(context, cubit),
                        const SizedBox(height: 24),
                        Text(
                          "how_old_are_you".tr(),
                          style: Omnes.w400.getStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: cubit.ageController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          maxLength: 2,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          validator: Validators.requiredField,
                          decoration: InputDecoration(
                            labelText: "age".tr(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "what_is_your_nationality".tr(),
                          style: Omnes.w400.getStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        DropdownSearch<Country>(
                          compareFn: (Country? a, Country? b) => a?.code == b?.code,
                          onSelected: cubit.onCountryChanged,
                          selectedItem: cubit.selectedCountry,
                          validator: (value) => Validators.requiredField(value?.name),
                          enabled: cubit.countries.isNotEmpty,
                          items: (filter, loadProps) => cubit.countries,
                          decoratorProps: DropDownDecoratorProps(
                            decoration: InputDecoration(
                                prefixIcon: _getPrefixIcon(cubit),
                                prefixIconConstraints: const BoxConstraints(
                                  maxWidth: 24 + 32,
                                  maxHeight: 24,
                                )),
                          ),
                          popupProps: PopupProps.modalBottomSheet(
                            modalBottomSheetProps: const ModalBottomSheetProps(
                              shape: SmoothRectangleBorder(
                                smoothness: 0.6,
                                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                              ),
                            ),
                            showSearchBox: true,
                            emptyBuilder: (context, searchEntry) {
                              return Align(
                                alignment: Alignment.topCenter,
                                child: Text("no_country_found".tr()),
                              );
                            },
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                hintText: "search_country".tr(),
                                prefixIcon: const Icon(Icons.search_rounded),
                                // enabledBorder: SmoothInputBorder(
                                //   borderRadius: BorderRadius.circular(8),
                                // ),
                              ),
                            ),
                            searchDelay: const Duration(milliseconds: 500),
                            itemBuilder: (context, item, isSelected, t) {
                              return ListTile(
                                title: Text("countries.${item.code.toUpperCase()}".tr()),
                                leading: getFlagImage(item),
                              );
                            },
                          ),
                          itemAsString: (value) => "countries.${value.code.toUpperCase()}".tr(),
                        ),
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

  Widget _buildNameFields(BuildContext context, WtUserDetailsFormCubit cubit) {
    final isRow = context.isMediumAndUp;
    return Flex(
      direction: isRow ? Axis.horizontal : Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: isRow ? 1 : 0,
          child: TextFormField(
            controller: cubit.firstNameController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            autofillHints: const [AutofillHints.givenName],
            keyboardType: TextInputType.name,
            inputFormatters: <TextInputFormatter>[UpperCaseTextFormatter()],
            textInputAction: TextInputAction.next,
            validator: Validators.requiredField,
            decoration: InputDecoration(
              labelText: "firstName".tr(),
            ),
          ),
        ),
        const SizedBox(width: 8, height: 8),
        Expanded(
          flex: isRow ? 1 : 0,
          child: TextFormField(
              controller: cubit.lastNameController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              autofillHints: const [AutofillHints.familyName],
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              validator: Validators.requiredField,
              decoration: InputDecoration(
                labelText: "lastName".tr(),
              )),
        ),
      ],
    );
  }

  Widget _buildGenderOptions(BuildContext context, WtUserDetailsFormCubit cubit) {
    void onGenderChanged(Gender? value) {
      if (value == null) return;
      cubit.onGenderChanged(value);
      context.read<WtAvatarsCubit>()
        ..gender = value
        ..fetchAvatars(value.isMale);
    }

    final isRow = context.isMediumAndUp;
    return Flex(
      direction: isRow ? Axis.horizontal : Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: isRow ? 1 : 0,
          child: CustomRadioListTile<Gender>(
            value: Gender.female,
            groupValue: cubit.gender,
            onChanged: onGenderChanged,
            title: Text("female".tr()),
          ),
        ),
        const SizedBox(width: 8, height: 8),
        Expanded(
          flex: isRow ? 1 : 0,
          child: CustomRadioListTile<Gender>(
            value: Gender.male,
            groupValue: cubit.gender,
            onChanged: onGenderChanged,
            title: Text("male".tr()),
          ),
        ),
      ],
    );
  }

  Widget? _getPrefixIcon(WtUserDetailsFormCubit cubit) {
    if (cubit.countries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: CircularProgressIndicator(),
      );
    } else {
      if (cubit.selectedCountry != null) {
        return getFlagImage(cubit.selectedCountry!);
      } else {
        return null;
      }
    }
  }

  Widget getFlagImage(Country country) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 24 + 32,
        maxHeight: 24,
      ),
      child: Center(
        child: CachedNetworkImage(
          imageUrl:Uri.encodeFull(country.fileName),
          memCacheWidth: 300,
          imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
          errorWidget: (context, url, error) {
            return Icon(
              Icons.flag_rounded,
              color: context.colorScheme.primary,
            );
          },
          placeholder: (context, url) {
            return const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: capitalize(newValue.text),
      selection: newValue.selection,
    );
  }
}

String capitalize(String value) {
  if (value.trim().isEmpty) return "";
  return "${value[0].toUpperCase()}${value.substring(1).toLowerCase()}";
}
