import 'package:educ_core/educ_core.dart';
import 'package:educ_student/core/assets.dart';
import 'package:material_ui/material_ui.dart';

class StarShapes extends StatelessWidget {
  const StarShapes({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 40,
            left: 16,
            child: _starShapeLeft(),
          ),
          Positioned(
            top: 0,
            left: 70,
            child: _starShapeLeft(),
          ),
          Positioned(
            top: 0,
            right: 70,
            child: _starShapeRight(),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: _starShapeRight(),
          ),
        ],
      ),
    );
  }

  Widget _starShapeLeft() {
    return SvgPicture.asset(Svgs.starLeft, width: 60, height: 60);
  }

  Widget _starShapeRight() {
    return SvgPicture.asset(Svgs.starRight, width: 60, height: 60);
  }
}
