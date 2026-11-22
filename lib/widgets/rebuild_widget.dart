import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Rebuild extends StatelessWidget {
  final Widget Function(BuildContext context, VoidCallback rebuild)? builder;

  const Rebuild({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RebuildCubit(),
      child: BlocBuilder<RebuildCubit, RebuildState>(
        builder: (context, state) {
          final cubit = context.read<RebuildCubit>();
          return builder?.call(context, cubit.rebuild) ?? Container();
        },
      ),
    );
  }
}

class RebuildCubit extends Cubit<RebuildState> {
  RebuildCubit() : super(RebuildInitial());

  void rebuild() {
    emit(RebuildTrigger());
  }
}

abstract class RebuildState {}

class RebuildInitial extends RebuildState {}

class RebuildTrigger extends RebuildState {}
