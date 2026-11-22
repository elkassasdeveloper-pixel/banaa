import 'package:educ_core/data/models/collection.dart';
import 'package:educ_core/data/repositories/collection_repository.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/helpers.dart';
import 'package:educ_core/utils/logger.dart';
import 'package:educ_core/utils/result.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WtCollectionsCubit extends Cubit<WtCollectionsState> {
  WtCollectionsCubit() : super(WtCollectionsInitial());

  final _collectionRepository = CollectionRepository();
  final formKey = GlobalKey<FormState>();

  Collection? selectedCollection;
  List<Collection> collections = [];

  Future<void> fetchRootCollections(String languageCode) async {
    emit(WtCollectionsLoading());

    final result = await _collectionRepository.getWalkthroughRootCollections(
      languageCode.toLowerCase(),
    );

    await result.fold((data) {
      collections = data;
      selectedCollection = collections.firstWhereOrNull(
        (element) =>
            element.himaIsActive == "Y" && element.himaIsVisable == "Y",
      );
      Logger.Blue("selectedCollection?.toMap()");
      Logger.Blue(selectedCollection?.toMap());
      emit(WtCollectionsLoaded());

      doPostFrame((_) {
        if (collections.isNotEmpty) {
          // onCollectionChanged(collections.first);
        }
      });
    }, (failure) => emit(WtCollectionsError(failure)));
  }

  void onCollectionChanged(Collection? value) {
    if (value != null) {
      selectedCollection = value;
    }
    emit(WtCollectionsChanged());
  }

  void reset() {}
}

@immutable
sealed class WtCollectionsState {}

final class WtCollectionsInitial extends WtCollectionsState {}

final class WtCollectionsLoading extends WtCollectionsState {}

final class WtCollectionsLoaded extends WtCollectionsState {}

final class WtCollectionsChanged extends WtCollectionsState {}

final class WtCollectionsError extends WtCollectionsState {
  final Failure failure;

  WtCollectionsError(this.failure);
}
