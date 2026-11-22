import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/widgets/error_message_card.dart';
import 'package:educ_student/core/assets.dart';
import 'package:educ_student/screens/other/certificates_cubit.dart';
import 'package:educ_student/widgets/back_arrow_button.dart';
import 'package:educ_student/widgets/certificate_tile.dart';
import 'package:educ_student/widgets/gradiant_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CertificatesScreen extends StatelessWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CertificatesCubit(),
      child: GradiantScreen(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              "certificates".tr(),
              style: Omnes.w400
                  .getStyle(color: context.colorScheme.primary, fontSize: 18.0),
            ),
            leading: const BackArrowButton(),
          ),
          body: _buildList(context),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return BlocBuilder<CertificatesCubit, CertificatesState>(
      builder: (context, state) {
        final cubit = context.read<CertificatesCubit>();
        final certificates = cubit.certificates;

        if (state is CertificatesLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is CertificatesError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ErrorMessageCard.failure(
                failure: state.failure,
                onRetry: cubit.fetch,
              ),
            ),
          );
        } else if (certificates == null) {
          return Center(
            child: Text("errors.empty_data".tr()),
          );
        } else {
          if(certificates.isEmpty ){
            return Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  Svgs.landscape,
                  fit: BoxFit.fill,
                ),
                Center(
                  child: Text(
                    "no certificates yet !".tr(),
                    style: Omnes.w600.getStyle(color: context.colorScheme.primary, fontSize: 18.0),
                  ),
                ),
              ],
            );
          }
          else{
          return RefreshIndicator(
            onRefresh: cubit.fetch,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
              ),
              itemCount: certificates.length,
              padding: const EdgeInsets.all(16.0),
              itemBuilder: (context, index) {
                final item = certificates[index];
                return CertificateTile(certificate: item);
              },
            ),
          );}
        }
      },
    );
  }
}
