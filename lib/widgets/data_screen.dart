import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/result.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/widgets/error_message_card.dart';
import 'package:educ_student/widgets/back_arrow_button.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DataScreen<C extends Cubit<S>, S> extends StatelessWidget {
  const DataScreen({
    super.key,
    this.cubit,
    this.buildWhen,
    required this.fetch,
    required this.isLoading,
    required this.isLoaded,
    required this.failure,
    this.isEmpty,
    required this.builder,
  });

  final C? cubit;
  final BlocBuilderCondition<S>? buildWhen;
  final Future<void> Function(C cubit) fetch;
  final bool Function(S state) isLoading;
  final bool Function(S state) isLoaded;
  final Failure? Function(S state) failure;
  final bool Function(C cubit, S state)? isEmpty;
  final Widget Function(BuildContext context, C cubit, S state) builder;

  @override
  Widget build(BuildContext context) {
    final cubit = this.cubit ?? context.read<C>();
    return RefreshIndicator(
      onRefresh: () => fetch.call(cubit),
      child: BlocBuilder<C, S>(
        bloc: cubit,
        buildWhen: buildWhen,
        builder: (context, state) {
          final cubit = context.read<C>();
          return Scaffold(
            appBar:
                failure(state) != null ||
                    isEmpty?.call(cubit, state) == true ||
                    isLoading(state)
                ? AppBar(leading: const BackArrowButton())
                : null,
            body: () {
              if (isLoading(state)) {
                return const Center(child: CircularProgressIndicator());
              } else if (isEmpty?.call(cubit, state) == true) {
                return Center(child: Text("errors.empty_data".tr(),style: Omnes.w700.getStyle(fontSize: 24,color: context.colorScheme.primary),));
              } else if (failure(state) != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ErrorMessageCard.failure(
                      failure: failure(state),
                      onRetry: () => fetch.call(cubit),
                    ),
                  ),
                );
              } else {
                return builder(context, cubit, state);
              }
            }(),
          );
        },
      ),
    );
  }
}
