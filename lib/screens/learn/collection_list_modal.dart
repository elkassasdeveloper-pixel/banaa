import 'package:educ_core/data/models/collection.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_student/screens/learn/learn_cubit.dart';
import 'package:educ_student/screens/learn/collection_expansion_tile.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CollectionListModal extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final List<Collection> rootCollections;
  final List<Collection> subCollections;
  final void Function(Collection) onRootCollectionSelected;
  final void Function(Collection) onSubCollectionSelected;
  final Collection? selectedRootCollection;
  final Collection? selectedSubCollection;

  const CollectionListModal({
    super.key,
    required this.isLoading,
    required this.error,
    required this.rootCollections,
    required this.subCollections,
    required this.onRootCollectionSelected,
    required this.onSubCollectionSelected,
    required this.selectedRootCollection,
    required this.selectedSubCollection,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.antiAlias,
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                _buildRootCollectionsTabs(context),
                if (error != null) _errorMessage(context) else _buildSubCollectionsCards(context),
              ],
            ),
          ),
        ),
        // if (isLoading)
        //   Positioned.fill(
        //     child: Container(
        //       alignment: Alignment.center,
        //       color: Colors.black87,
        //       child: const CircularProgressIndicator(),
        //     ),
        //   ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          Expanded(
            child: Text(
              "choose_science".tr(),
              style: Omnes.w700.getStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 16.0),
          if (isLoading) ...[
            const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(),
            ),
            const SizedBox(width: 8),
          ],
          IconButton(
            onPressed: context.pop,
            icon: const Icon(Icons.close_rounded),
          ),
          /*   IconButton(
            onPressed: () => context.read<LearnCubit>().fetch(),
            icon: const Icon(Icons.refresh),
          ),*/
        ],
      ),
    );
  }

  Widget _buildRootCollectionsTabs(BuildContext context) {
    final cubit = context.read<LearnCubit>();
    final visibleRootCollections = rootCollections.where((c) => c.himaIsVisable == "Y").toList();
    return SizedBox(
      height: 36 + 32,
      child: SingleChildScrollView(
        controller: cubit.rootCollectionsScrollController,
        scrollDirection: Axis.horizontal,
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: visibleRootCollections.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final collection = visibleRootCollections[index];
            final isSelected = selectedRootCollection?.id == collection.id;
            final isEnabled = collection.himaIsActive == "Y";

            return TextButton(
              key: isSelected ? cubit.selectedRootCollectionKey : null,
              onPressed: (isLoading || !isEnabled) ? null : () => onRootCollectionSelected(collection),
              style: TextButton.styleFrom(
                foregroundColor: context.colorScheme.inverseSurface,
                backgroundColor: isSelected
                    ? context.colorScheme.inverseSurface.alphaBlend(context.colorScheme.surface, 0.15)
                    : null,
                textStyle: (isSelected ? Omnes.w700 : Omnes.w400).getStyle(fontSize: 14),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: const Size(32, 36),
              ),
              child: Text(collection.name),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(width: 8),
        ),
      ),
    );
  }

  Widget _buildSubCollectionsCards(BuildContext context) {
    final visibleSubCollections = subCollections.where((c) => c.himaIsVisable == "Y").toList();

    return Expanded(
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        itemCount: visibleSubCollections.length,
        itemBuilder: (context, index) {
          final collection = visibleSubCollections[index];
          final isSelected = selectedSubCollection?.id == collection.id;
          final isEnabled = collection.himaIsActive == "Y";

          return CollectionExpansionTile(
            collection: collection,
            isSelected: isSelected,
            enabled: !isLoading && isEnabled,
            onTap: () => onSubCollectionSelected(collection),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 8),
      ),
    );
  }

  Widget _errorMessage(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          error ?? "",
          style: Omnes.w400.getStyle(fontSize: 16, color: context.colorScheme.error),
        ),
      ),
    );
  }
}
