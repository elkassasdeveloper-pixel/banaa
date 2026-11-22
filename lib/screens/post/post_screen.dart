import 'package:educ_core/educ_core.dart';
import 'package:educ_student/screens/post/post_cubit.dart';
import 'package:educ_student/screens/community/post_item.dart';
import 'package:educ_student/widgets/data_screen.dart';
import 'package:material_ui/material_ui.dart';

class PostScreen extends StatelessWidget {
  const PostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DataScreen<PostCubit, PostState>(
      fetch: (cubit) => cubit.fetchPost(silent: true),
      isLoading: (state) => state is PostLoading,
      isLoaded: (state) => state is PostLoaded,
      failure: (state) => state is PostError ? state.failure : null,
      isEmpty: (cubit, state) => cubit.post == null,
      builder: (context, cubit, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text("post".tr()),
          ),
          body: PostItem(
            pageController: cubit.secondaryPageController,
            cubit: cubit,
            isExpanded: true,
          ),
        );
      },
    );
  }
}
