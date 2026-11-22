import 'package:material_ui/material_ui.dart';

class LoggingInWidget extends StatelessWidget {
  const LoggingInWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(
        child: Container(
          color: Colors.black12,
        ),
      ),
      const Center(
        child: Card(
          elevation: 8,
          color: Colors.white,
          shape: StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    ]);
  }
}
