import 'package:educ_core/data/models/chat_message.dart';
import 'package:material_ui/material_ui.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({super.key, required this.sender, required this.msg});

  final bool sender;
  final ChatMessage msg;

  @override
  Widget build(BuildContext context) {
    final constraints =
        BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
            maxWidth: MediaQuery.of(context).size.width);
    return Row(
      mainAxisAlignment:
      sender ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
maxWidth: constraints.maxWidth * 0.7
          ),
          child: Container(
            decoration: BoxDecoration(
                color: sender ? Color.fromRGBO(0, 215, 100, 0.1) : Color.fromRGBO(112, 153, 215, 0.1), borderRadius: sender ? BorderRadius.only(
                bottomRight: Radius.circular(32)):BorderRadius.only(
                bottomLeft: Radius.circular(32))),
            child:   Column(
              crossAxisAlignment: sender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        msg.userName,
                        style: TextStyle(color: Color.fromRGBO(112, 153, 215, 1), fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                    ),
                SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      msg.text,
                      style: TextStyle(color: Color.fromRGBO(42, 46, 53, 1), fontSize: 12, fontWeight: FontWeight.w400),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
