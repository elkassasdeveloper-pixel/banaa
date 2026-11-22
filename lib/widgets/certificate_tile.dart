import 'package:educ_core/data/models/certificate.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
import 'package:educ_student/core/assets.dart';
import 'package:material_ui/material_ui.dart';

class CertificateTile extends StatelessWidget {
  const CertificateTile({super.key, required this.certificate});

  final Certificate certificate;

  @override
  Widget build(BuildContext context) {
    return _buildImage(certificate.imageFileName, context);
  }

  Widget _buildImage(String image, BuildContext context) {
    return CachedNetworkImage(
      imageUrl:Uri.encodeFull(image),
      memCacheWidth: 300,
      imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
      fit: BoxFit.cover,
      placeholder: (c, s) {
        return Container(
          color: context.colorScheme.surfaceContainer,
        );
      },
      errorWidget: (context, url, error) {
        return Container(
          decoration: ShapeDecoration(
            color: context.colorScheme.surfaceContainerHighest,
            shape: SmoothRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                width: 64.0,
                height: 64.0,
                Svgs.certificate,
                colorFilter: context.colorScheme.primary
                    .withValues(alpha: 0.3)
                    .toColorFilter(),
              ),
              const SizedBox(height: 8.0),
              Text(
                certificate.title,
                textAlign: TextAlign.center,
                style: Omnes.w700.getStyle(
                    color: context.colorScheme.primary, fontSize: 16.0),
              ),
            ],
          ),
        );
      },
    );
  }
}
