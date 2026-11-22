import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/widgets/error_message_card.dart';
import 'package:educ_student/core/assets.dart';
import 'package:educ_student/screens/other/bookmarks_cubit.dart';
import 'package:educ_student/widgets/back_arrow_button.dart';
import 'package:educ_student/widgets/gradiant_screen.dart';
import 'package:educ_student/widgets/topic_bookmark_tile.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BookmarksCubit(),
      child: GradiantScreen(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              "bookmarks".tr(),
              style: Omnes.w400.getStyle(color: context.colorScheme.primary, fontSize: 18.0),
            ),
            leading: const BackArrowButton(),
          ),
          body: _buildList(context),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return BlocBuilder<BookmarksCubit, BookmarksState>(builder: (context, state) {
      final cubit = context.read<BookmarksCubit>();
      final bookmarks = cubit.bookmarks;

      if (state is BookmarksLoading) {
        return const Center(child: CircularProgressIndicator());
      } else {
        return RefreshIndicator(
          onRefresh: cubit.fetch,
          child: () {
            if (state is BookmarksError) {
              return Center(
                child: ErrorMessageCard.failure(
                  failure: state.failure,
                  onRetry: cubit.fetch,
                ),
              );
            } else if (bookmarks == null) {
              return Center(child: Text("errors.empty_data".tr()));
            } else {
              if (bookmarks.isEmpty) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      Svgs.landscape,
                      fit: BoxFit.fill,
                    ),
                    Center(
                      child: Text(
                        "no bookmarks yet !".tr(),
                        style: Omnes.w600.getStyle(color: context.colorScheme.primary, fontSize: 18.0),
                      ),
                    ),
                  ],
                );

              } else {
                return ListView.separated(
                  itemCount: bookmarks.length,
                  padding: const EdgeInsets.all(16.0),
                  itemBuilder: (context, index) {
                    final bookmark = bookmarks[index];
                    return TopicBookmarkTile(
                      topic: bookmark,
                      fetchAllTopics: cubit.fetch,
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      height: 16.0,
                    );
                  },
                );
              }
            }
          }(),
        );
      }
    });
  }
}
