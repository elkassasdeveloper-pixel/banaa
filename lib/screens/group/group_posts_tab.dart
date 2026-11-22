import 'package:educ_core/educ_core.dart';
import 'package:educ_core/widgets/error_message_card.dart';
import 'package:educ_student/screens/group/group_posts_cubit.dart';
import 'package:educ_student/screens/post/post_cubit.dart';
import 'package:educ_student/screens/community/post_item.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupPostsTab extends StatelessWidget {
  const GroupPostsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupPostsCubit, GroupPostsState>(
      builder: (context, state) {
        final cubit = context.read<GroupPostsCubit>();
        final posts = cubit.filteredPosts;

        if (state is GroupPostsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is GroupPostsError) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ErrorMessageCard.failure(
              failure: state.failure,
              onRetry: cubit.fetch,
            ),
          );
        } else if (posts.isEmpty) {
          return Center(child: Text("errors.empty_data".tr()));
        }

        return RefreshIndicator(
          onRefresh: cubit.fetch,
          child: ListView.separated(
            itemCount: posts.length,
            padding: const EdgeInsets.only(bottom: 64.0),
            itemBuilder: (context, index) {
              final post = posts[index];
              final cubit = PostCubit(post: post);
              return BlocProvider(
                create: (context) => cubit,
                child: PostItem(
                  pageController: cubit.primaryPageController,
                  cubit: cubit,
                  isExpanded: false,
                ),
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 16.0);
            },
          ),
        );
      },
    );
  }
}
