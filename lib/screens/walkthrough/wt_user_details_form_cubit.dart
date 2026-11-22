import 'package:educ_core/constants/enums.dart';
import 'package:educ_core/data/models/country.dart';
import 'package:educ_core/data/repositories/country_repository.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/helpers.dart';
import 'package:educ_core/utils/result.dart';
import 'package:educ_student/core/constants.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WtUserDetailsFormCubit extends Cubit<WtUserFormState> {
  WtUserDetailsFormCubit() : super(WtUserFormInitial());

  final formKey = GlobalKey<FormState>();
  final _countryRepository = CountryRepository();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final ageController = TextEditingController();

  Gender gender = Consts.defaultGender;

  Country? selectedCountry;
  List<Country> countries = [];

  Future<void> fetchAllCountries() async {
    emit(WtUserFormLoading());

    final result = await _countryRepository.getAllCountries();

    await result.fold(
      (data) {
        countries = data;
        emit(WtUserFormLoaded());

        if (countries.isNotEmpty) {
          doPostFrame((_) {
            const sau = "KSA";
            final defaultCountry = countries.firstWhereOrNull(
              (element) => element.code == sau,
            );
            onCountryChanged(defaultCountry);
          });
        }
      },
      (failure) => emit(WtUserFormError(failure)),
    );
  }

  void onGenderChanged(Gender? value) {
    if (value != null) {
      gender = value;
    }
    emit(WtUserFormChanged());
  }

  void onCountryChanged(Country? value) {
    if (value != null) {
      selectedCountry = value;
    }
    emit(WtUserFormChanged());
  }

  void reset() {
    formKey.currentState?.reset();
    firstNameController.clear();
    lastNameController.clear();
    ageController.clear();
    gender = Gender.female;
    selectedCountry = null;
    emit(WtUserFormInitial());
  }

  @override
  Future<void> close() {
    reset();

    return super.close();
  }
}


@immutable
sealed class WtUserFormState {}

final class WtUserFormInitial extends WtUserFormState {}

final class WtUserFormLoading extends WtUserFormState {}

final class WtUserFormLoaded extends WtUserFormState {}

final class WtUserFormChanged extends WtUserFormState {}

final class WtUserFormError extends WtUserFormState {
  final Failure failure;

  WtUserFormError(this.failure);
}
