import 'package:educ_core/utils/helpers.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:material_ui/material_ui.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        alignment: Alignment.center,
        color: Colors.black54,
        child: Card(
            // margin: const EdgeInsets.all(32.0),
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: Omnes.w700.getStyle(fontSize: 16),
                )
              ],
            ],
          ),
        )),
      ),
    );
  }

  static Future<void> show(
    BuildContext context,
    Future Function() fun, {
    String? message,
  }) async {
    doPostFrame((_) async {
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black54,
        builder: (context) => LoadingIndicator(message: message),
      );

      fun().then((value) {if(context.mounted) Navigator.pop(context);});
    });
  }
}
