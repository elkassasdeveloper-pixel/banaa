import 'package:educ_core/data/models/certificate.dart';
import 'package:educ_core/data/repositories/account_repository.dart';
import 'package:educ_core/utils/result.dart';
import 'package:educ_student/data_cubit.dart';
import 'package:flutter/foundation.dart';

class CertificatesCubit extends DataCubit<CertificatesState> {
  CertificatesCubit() : super(CertificatesInitial()) {
    fetch();
  }

  List<Certificate>? certificates;
  final _accountRepository = AccountRepository();

  @override
  Future<void> fetch() async {
    await fetchCertificates();
  }

  Future<void> fetchCertificates() async {
    emit(CertificatesLoading());
    final result = await _accountRepository.getCertificates();
    result.fold(
      (data) {
        certificates = data;
        emit(CertificatesLoaded());
      },
      (failure) => emit(CertificatesError(failure)),
    );
  }
}
@immutable
sealed class CertificatesState {}

final class CertificatesInitial extends CertificatesState {}

final class CertificatesLoading extends CertificatesState {}

final class CertificatesLoaded extends CertificatesState {}

final class CertificatesError extends CertificatesState {
  final Failure failure;

  CertificatesError(this.failure);
}
