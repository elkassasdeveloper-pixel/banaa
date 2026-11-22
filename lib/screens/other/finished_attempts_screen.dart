import 'package:auto_size_text/auto_size_text.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
import 'package:educ_student/core/assets.dart';
import 'package:educ_student/core/brand_colors.dart';
import 'package:educ_student/widgets/banaa_button.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class FinishedAttemptsScreen extends StatelessWidget {
  const FinishedAttemptsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = context.mediaQuery.size.width;
    final screenWidthRatio = context.mediaQuery.size.width / 1440;
    final isMobile = screenWidth < 600;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 120,
        leading: Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: context.pop,
            icon: SvgPicture.asset(
              Svgs.backArrow,
              colorFilter: context.colorScheme.primary.toColorFilter(),
              matchTextDirection: true,
            ),
            label: Text("back".tr()),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              foregroundColor: Theme.of(context).colorScheme.primary,
              // minimumSize: const Size(48, 30),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: isMobile ? 16 : 200 * screenWidthRatio),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                        /*width: screenWidth-300,*/
                        height: 170,
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(225, 241, 255, 1), borderRadius: BorderRadius.circular(16)),
                        child: Image.asset(Images.assistant)),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text("You_have_finished_your_attempts".tr(),
                  style: Omnes.w700.getStyle(color: context.colorScheme.primary, fontSize: 20)),
              SizedBox(height: 8),
              Text("Add_a_new_attempt_or_wait_until_your_attempts_are_full_again.".tr(),
                  style: Omnes.w400.getStyle(color: context.colorScheme.primary, fontSize: 16)),
              SizedBox(height: 8),
              Row(
                children: [
                  _buildResultBlock(context, "0:52", Svgs.time),
                  const SizedBox(width: 8.0),
                  _buildResultBlock(context, "100%", Svgs.target),
                  const SizedBox(width: 8.0),
                  _buildResultBlock(context, "0", Svgs.achievementCup),
                ],
              ),
              const SizedBox(height: 16.0),
              _buildNextTopicButton(context),
              const SizedBox(height: 16.0),
              _buildAddTasbehatButton(context),
              const SizedBox(height: 16.0),
              // if (!isAdvancedQuiz)
              ..._buildStandardQuizOptions(context)
              // else
              //   ..._buildAdvancedQuizOptions(context)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultBlock(BuildContext context, String label, String iconPath) {
    const color = BrandColors.error; /*isAdvancedQuizFailed
        ? */ // context.colorScheme.outlineVariant;
    // : BrandColors.secondary1;

    return Expanded(
      child: Container(
        constraints: const BoxConstraints(minHeight: 48.0),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        decoration: ShapeDecoration(
          shape: SmoothRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: color,
              width: 1.5,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: AutoSizeText(
                label,
                minFontSize: 14,
                maxLines: 1,
                style: Omnes.w600.getStyle(fontSize: 20, color: color),
              ),
            ),
            const SizedBox(width: 8.0),
            SvgPicture.asset(
              iconPath,
              width: 20,
              height: 20,
              colorFilter: color.toColorFilter(),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStandardQuizOptions(BuildContext context) {
    return [
      BanaaButton.accentSurface(
        label: "return_to_the_main_page".tr(),
        accentColor: context.colorScheme.primary,
        onPressed: () {
          Navigator.pop(context);
          // context.goNamed(Routes.LEARN);
        },
      )
    ];
  }

  Widget _buildNextTopicButton(BuildContext context) {
    return BanaaButton(
      label: "Add_an_attempt_by_taking_a_test".tr(),
      onPressed: () async {},
      prefixIcon: SvgPicture.asset(
        Svgs.attemptsHeart,
        colorFilter:ColorFilter.mode(BrandColors.error, BlendMode.srcIn)
      ),
    );
  }

  Widget _buildAddTasbehatButton(BuildContext context) {
    return BanaaButton(
      label: "Add_an_attempt_after_Tasbihat".tr(),
      onPressed: () async {
        showCustomPopup(context);
      },
      backgroundColor: BrandColors.secondary1,prefixIcon: SvgPicture.asset(
        Svgs.attemptsHeart,
        colorFilter:ColorFilter.mode(BrandColors.error, BlendMode.srcIn)
    ),
    );
  }
}

void showCustomPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return BlocProvider(
        create: (context) => CounterCubit(),
        child: BlocBuilder<CounterCubit, CounterState>(
          builder: (context, state) {
            final cubit = context.read<CounterCubit>();
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Container(
                width: 335,
                // height: 410,
                padding: EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: context.pop,
                          icon: SvgPicture.asset(
                            Svgs.backArrow,
                            colorFilter: context.colorScheme.primary.toColorFilter(),
                            matchTextDirection: true,
                          ),
                          label: Text("back".tr()),
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            foregroundColor: Theme.of(context).colorScheme.primary,
                            // minimumSize: const Size(48, 30),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: BrandColors.error,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    Image.asset(
                      "assets/images/on_boarding_3.png", // replace with your asset path
                      height: 100,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Count 100 tasbeehs to add an attempt".tr(),
                      textAlign: TextAlign.center,
                      style: Omnes.w700.getStyle(fontSize: 20, color: BrandColors.primary2),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Remember Allah or send blessings upon the beloved. You can complete the same test after completing. One second for every repetition. You can cheat if you do not take into account God's control. So earn a reward that will last for you."
                          .tr(),
                      textAlign: TextAlign.center,
                      style: Omnes.w400.getStyle(fontSize: 16, color: BrandColors.grey.withValues(alpha: .6)),
                    ),
                    SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        cubit.addGoodDeed();
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(color: BrandColors.babyBlue),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '+',
                              style: Omnes.w700.getStyle(fontSize: 20, color: BrandColors.primary2),
                            ),
                            SizedBox(width: 10),
                            Text(
                              cubit.counter.toString(),
                              style: Omnes.w700.getStyle(fontSize: 20, color: BrandColors.primary2),
                            ),
                            SizedBox(width: 10),
                            Text(
                              "good_deed".tr(),
                              style: Omnes.w700.getStyle(fontSize: 20, color: BrandColors.primary2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(CounterInitial());
  int counter = 0;

  void addGoodDeed() {
    counter++;
    emit(CounterIncrease());
  }
}

abstract class CounterState {}

class CounterInitial extends CounterState {}

class CounterIncrease extends CounterState {}
// class CounterInitial extends CounterState{}
