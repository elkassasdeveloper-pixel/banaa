import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/widgets/error_message_card.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
import 'package:educ_student/core/assets.dart';
import 'package:educ_student/core/extensions.dart';
import 'package:educ_student/core/routes.dart';
import 'package:educ_student/screens/community/community_groups_cubit.dart';
import 'package:educ_student/screens/community/community_sliver_app_bar.dart';
import 'package:educ_student/screens/community/post_item.dart';
import 'package:educ_student/screens/main_screen.dart';
import 'package:educ_student/screens/post/popular_posts_cubit.dart';
import 'package:educ_student/screens/post/post_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  static const double minAppBarHeight = 124;
  static const double maxAppBarHeight = 276 + 24.0;

  @override
  Widget build(BuildContext context) {
    if (!context.read<CommunityGroupsCubit>().showAssistantBefore) {
      context.assistant.setEvent(13);
      context.assistant.start();
      context.read<CommunityGroupsCubit>().showAssistantBefore = true;
    }
    return RefreshIndicator(
      onRefresh: () async {
        Future.wait([
          context.read<CommunityGroupsCubit>().fetchGroups(),
          context.read<PopularPostsCubit>().fetchPopularPosts(),
        ]);
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            const CommunitySliverAppBar(
              minExtent: minAppBarHeight,
              maxExtent: maxAppBarHeight,
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverToBoxAdapter(
                child: Text(
                  "popular_posts".tr(),
                  style: Omnes.w500.getStyle(
                      fontSize: 20, color: context.colors.subHeadline),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            _buildPopularPostsList(context),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          tooltip: "chats".tr(),
          onPressed: () {
            context.goNamed(Routes.CHAT);
          },
          shape: SmoothRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: context.colorScheme.tertiaryContainer,
          foregroundColor: context.colorScheme.onTertiaryContainer,
          label: Text("chats".tr()),
          icon: SvgPicture.asset(
            Svgs.chat,
            colorFilter:
                context.colorScheme.onTertiaryContainer.toColorFilter(),
          ),
        ),
      ),
    );
  }

  Widget _buildPopularPostsList(BuildContext context) {
    return BlocBuilder<PopularPostsCubit, PopularPostsState>(
      builder: (context, state) {
        final cubit = context.read<PopularPostsCubit>();
        final posts = cubit.filteredPosts;

        if (state is PopularPostsLoading) {
          return const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is PopularPostsError) {
          return SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ErrorMessageCard.failure(
                  failure: state.failure,
                  onRetry: cubit.fetch,
                ),
              ),
            ),
          );
        } else if (posts.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Text("errors.empty_data".tr()),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.only(bottom: 64.0),
          sliver: SliverList.separated(
            itemCount: posts.length,
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
              // return Divider(
              //   thickness: 1.0,
              //   indent: 16.0,
              //   endIndent: 16.0,
              //   color: context.colorScheme.primary.withValues(alpha: 0.1),
              // );
              return const SizedBox(height: 16.0);
            },
          ),
        );
      },
    );
  }
}
