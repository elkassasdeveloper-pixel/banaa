import 'package:educ_core/data/models/chat_message.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/services/centrifugo/conf.dart' as conf;
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_student/screens/chat/chat_cubit.dart';
import 'package:educ_student/screens/chat/message_widget.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  static const String routeName = 'chat-screen';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit()..init(),
      child: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          final cubit = context.read<ChatCubit>();
          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromRGBO(240, 246, 255, 1),
              leading: Row(
                children: [
                  const SizedBox(width: 25),
                  InkWell(
                    onTap: () {
                      context.pop();
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 24,
                      color: Color.fromRGBO(112, 153, 215, 1),
                    ),
                  ),
                ],
              ),
              title: Row(
                children: [
                  Image.asset(
                    "assets/images/welcome_boy.png",
                    height: 40,
                    width: 40,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "saeed",
                        style: TextStyle(
                          color: Color.fromRGBO(112, 153, 215, 1),
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        "admin".tr(),
                        style: TextStyle(
                          color: Color.fromRGBO(112, 153, 215, 0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            body: cubit.connected && !cubit.error && !conf.cli.isError
                ? Container(
                    color: const Color.fromRGBO(240, 246, 255, 1),
                    child: Column(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child:
                                ListView.builder( controller: cubit.scrollController,
                                    shrinkWrap: true,
                                    itemCount: cubit.msgs.length,itemBuilder: (context, index) {
                                  final msg = cubit.msgs[index];
                                  return  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 8),
                                    child: MessageWidget(msg: msg,sender: msg.userId == conf.userId),
                                  );
                                    },

                                ),
                            ),
                          ),
                        ),
                        TextField(
                          controller: cubit.controller,
                          focusNode: cubit.focusNode,
                          textInputAction: TextInputAction.send,
                          onChanged: (value) => cubit.onTextChange(value),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              cubit.sendMessage(
                                context,
                                ChatMessage(
                                  userId: conf.userId,
                                  userName: conf.userName,
                                  text: value,
                                  createdAt: DateTime.now(),
                                ),
                              );
                            }
                          },
                          decoration: InputDecoration(
                            hintText: "Enter your message here ....".tr(),
                            // border: OutlineInputBorder(
                            //   borderRadius: BorderRadius.circular(10),
                            // ),
                            filled: true,
                            fillColor: Colors.white,
                            hintStyle: TextStyle(
                              color: Color.fromRGBO(112, 153, 215, 0.5),
                            ),
                            prefixIcon: IconButton(
                              icon: Icon(Icons.message_outlined, size: 16),
                              onPressed: () {
                                if(cubit.text.trim().isNotEmpty){
                                  cubit.sendMessage(
                                    context,
                                    ChatMessage(
                                      userId: conf.userId,
                                      userName: conf.userName,
                                      text: cubit.text,
                                      createdAt: DateTime.now(),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          style: TextStyle(height: 4.1),
                          cursorHeight: 30,
                        ),
                      ],
                    ),
                  )
                : cubit.error || conf.cli.isError
                ? Center(
                    child: Text(
                      "error.internal_server_error",
                      style: Omnes.w700.getStyle(fontSize: 24),
                    ).tr(),
                  )
                : const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
