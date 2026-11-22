import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DataCubit<T extends Object> extends Cubit<T> {
  DataCubit(super.initialState) {
    cubits.add(this);
  }

  static final List<DataCubit> cubits = [];

  static List<DataCubit> get providers => cubits;

  static Future<void> onLanguageChanged() async {
    for (final cubit in cubits) {
      try {
        await cubit.fetch();
      } catch (_) {}
    }
  }

  Future<void> fetch();

  @override
  Future<void> close() async {
    cubits.remove(this);
    super.close();
  }
}
