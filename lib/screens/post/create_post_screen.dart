import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_student/screens/post/add_post_cubit.dart';
import 'package:educ_student/screens/post/custom_quill_editor.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddPostCubit(),
      child: BlocBuilder<AddPostCubit, AddPostCubitState>(
        builder: (context, state) {
          final cubit = context.read<AddPostCubit>();
          return Scaffold(
            appBar: AppBar(
              actions: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12.5),
                  child: InkWell(
                    onTap: () {
                      if (!cubit.quillController.document.isEmpty()) {
                        cubit.addPost(context);
                      }
                    },
                    child: Text("Post".tr(), style: Omnes.w700.getStyle(color: context.colorScheme.primary, fontSize: 18.0)),
                  ),
                ),
              ],
              // title: ,
              leading: InkWell(
                onTap: () {
                  context.pop();
                },
                child: Icon(Icons.arrow_back_ios, color: Color.fromRGBO(0, 86, 128, 1), size: 18),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(child: CustomQuillEditor(controller: cubit.quillController)),
            ),
          );
        },
      ),
    );
  }
}
