import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_student/core/brand_colors.dart';
import 'package:educ_student/screens/other/help_center_question_widget.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "help".tr(),
            style: Omnes.w700.getStyle(
              fontSize: 18.0,
              color: BrandColors.primary2,
            ),
          ),
          leading: Row(
            children: [
              SizedBox(width: 20),
              InkWell(
                onTap: () {
                  context.pop();
                },
                child: Icon(
                  Icons.arrow_back_ios,
                  color: BrandColors.primary2,
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              HelpCenterQuestionWidget(
                question: "س. ما هي الجمعية المسؤولة عن هذا التطبيق؟",
                answer: "ج. الجمعية المسؤولة هي 'جمعية الدعوة والإرشاد وتوعية الجاليات بخميس مشيط'، وهي جهة رسمية تعمل على نشر قيم الإسلام وتعليم الجاليات بالحكمة والموعظة الحسنة.",
              ),
              const SizedBox(height: 16),

              HelpCenterQuestionWidget(
                question: "س. ما أهداف الجمعية؟",
                answer: "ج. تهدف الجمعية إلى نشر الدعوة الإسلامية، توعية الجاليات بلغاتهم، تقديم برامج تعليمية، والمساهمة في بناء قيم إيجابية في المجتمع.",
              ),
              const SizedBox(height: 16),

              HelpCenterQuestionWidget(
                question: "س. هل الجمعية معترف بها رسميًا؟",
                answer: "ج. نعم، الجمعية مرخصة من المركز الوطني لتنمية القطاع غير الربحي، وتعمل ضمن الأطر الرسمية في المملكة العربية السعودية.",
              ),
              const SizedBox(height: 16),

              HelpCenterQuestionWidget(
                question: "س. هل الجمعية تقدم خدمات لغير المسلمين؟",
                answer: "ج. نعم، الجمعية تهتم بتعريف غير المسلمين بالإسلام بلغة مفهومة لهم، وتوفر برامج تثقيفية ودورات تعريفية بلغات مختلفة.",
              ),
              const SizedBox(height: 16),

              HelpCenterQuestionWidget(
                question: "س. هل يمكنني دعم الجمعية؟",
                answer: "ج. نعم، يمكنك دعم الجمعية بالتبرع، أو التطوع، أو نشر مشاريعها وبرامجها الدعوية والتعليمية. يمكن زيارة الموقع الرسمي للمزيد.",
              ),
              const SizedBox(height: 16),

              HelpCenterQuestionWidget(
                question: "س. ما علاقة الجمعية بالتقنية؟",
                answer: "ج. الجمعية تتبنى التحول الرقمي بشكل كبير، وتسعى لتقديم الدعوة والتعليم عبر التطبيقات والمنصات التقنية مثل تطبيق 'بناء'.",
              ),
              const SizedBox(height: 16),

              HelpCenterQuestionWidget(
                question: "س. أين تقع الجمعية؟",
                answer: "ج. مقر الجمعية في مدينة خميس مشيط، المملكة العربية السعودية، ويمكن التواصل معهم إلكترونيًا عبر موقعهم الرسمي.",
              ),

              const SizedBox(height: 16),
              HelpCenterQuestionWidget(
                question: "س. كيف يمكنني تعديل الملف الشخصي؟",
                answer:
                "ج. من خلال صفحة الإعدادات، اختر 'تعديل الملف الشخصي'، ثم يمكنك تغيير الاسم، الصورة، أو بيانات أخرى مرتبطة بحسابك.",
              ),
              const SizedBox(height: 16),
              HelpCenterQuestionWidget(
                question: "س. كيف أستطيع تغيير كلمة المرور؟",
                answer:
                "ج. انتقل إلى 'تغيير كلمة المرور' في الإعدادات، أدخل كلمة المرور القديمة والجديدة، ثم اضغط 'تأكيد' لحفظ التغييرات.",
              ),
              const SizedBox(height: 16),
              HelpCenterQuestionWidget(
                question: "س. كيف أفعل تذكيرات المذاكرة؟",
                answer:
                "ج. من خلال صفحة 'الإشعارات'، يمكنك تفعيل خيار 'تذكيرات المذاكرة' وتحديد الوقت المناسب لك لتلقي الإشعار.",
              ),
              const SizedBox(height: 16),
              HelpCenterQuestionWidget(
                question: "س. ما فائدة تذكيرات المجتمع؟",
                answer:
                "ج. هذه التذكيرات تُستخدم لتنبيهك بالمشاركات أو الأنشطة الجديدة داخل مجتمع المتعلمين في التطبيق.",
              ),
              const SizedBox(height: 16),
              HelpCenterQuestionWidget(
                question: "س. كيف أضبط وقت التذكير؟",
                answer:
                "ج. افتح إعدادات 'الإشعارات'، واضغط على 'وقت التذكير'، ثم اختر الساعة المناسبة التي تريد استقبال التذكير فيها.",
              ),
              const SizedBox(height: 16),
              HelpCenterQuestionWidget(
                question: "س. كيف يمكنني تغيير وضع المظهر (النهاري/الليلي)؟",
                answer:
                "ج. من الإعدادات العامة، اختر 'وضع المظهر'، ثم حدد الوضع المفضل لديك سواء كان فاتحًا أو داكنًا.",
              ),
              const SizedBox(height: 16),
              HelpCenterQuestionWidget(
                question: "س. ما المقصود بالمؤثرات الصوتية؟ وهل يمكن تعطيلها؟",
                answer:
                "ج. المؤثرات الصوتية هي أصوات تفاعلية داخل التطبيق. يمكنك تفعيلها أو تعطيلها من خلال إعدادات 'الإعدادات العامة'.",
              ),
              const SizedBox(height: 16),
              HelpCenterQuestionWidget(
                question: "س. كيف أتابع تقدمي في الكورس؟",
                answer:
                "ج. من صفحة 'التعلّم'، يوجد شريط يوضح نسبة التقدم في المسار. كل درس مكتمل يزيد من هذه النسبة تلقائيًا.",
              ),
              const SizedBox(height: 16),
              HelpCenterQuestionWidget(
                question: "س. لماذا بعض الدروس عليها علامة القمر؟",
                answer:
                "ج. هذه العلامة تشير إلى أن الدرس مصمم بأسلوب التأمل أو الاسترخاء، ويمكنك دراسته في وقت هادئ مثل الليل.",
              ),
              const SizedBox(height: 16),
              HelpCenterQuestionWidget(
                question: "س. كم مدة كل درس تقريبًا؟",
                answer:
                "ج. كل درس موضح تحته المدة الزمنية (غالبًا بين دقيقة إلى ثلاث دقائق)، لتتمكن من تنظيم وقتك بسهولة.",
              ),
              const SizedBox(height: 16),
            ],
          )


        ));
  }
}
