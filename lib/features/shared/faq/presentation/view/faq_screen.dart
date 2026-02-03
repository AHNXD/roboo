import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/core/widgets/dot_background.dart';

class FaqScreen extends StatelessWidget {
  static const String routeName = '/faq';
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "الأسئلة الشائعة"),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: DotBackground()),
            Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      _FaqTile(
                        question: "كيف أبدأ بتعلّم الروبوتيك؟",
                        answer: """ابدأ بالتعلّم خطوة بخطوة! 🚀
الروبوتيك يعني دمج الهندسة والبرمجة لصنع روبوتات تستطيع أداء مهام حقيقية.
في البداية، تعلم كيف يعمل الروبوت من خلال ثلاث مراحل بسيطة:

اكتشف الأجزاء الأساسية:
المحركات ⚙️، المستشعرات 👀، ولوحة التحكم 🧠.
هذه هي المكونات التي تجعل الروبوت يتحرك و "يفكر".

تعلّم البرمجة بطريقة ممتعة:
استخدم أدوات مثل Scratch أو Blockly لبرمجة روبوتك عبر السحب والإفلات.
لاحقاً، يمكنك الانتقال إلى لغات أكثر احترافية مثل Python.""",
                        isExpanded: true,
                      ),
                      const SizedBox(height: 16),
                      _FaqTile(
                        question:
                            "ما اللغة البرمجية التي أستخدمها لأبرمج الروبوت؟",
                        answer:
                            "يمكنك البدء بـ Block-based coding ثم الانتقال إلى Python أو C++.",
                      ),
                      const SizedBox(height: 16),
                      _FaqTile(
                        question:
                            "هل يمكنني تعلّم الذكاء الاصطناعي من خلال التطبيق؟",
                        answer:
                            "نعم، يوفر التطبيق مسارات تعليمية مخصصة للذكاء الاصطناعي.",
                      ),
                      const SizedBox(height: 16),
                      _FaqTile(
                        question:
                            "هل الألعاب في التطبيق تساعدني على التعلم فعلاً؟",
                        answer:
                            "بالتأكيد! الألعاب مصممة لتعزيز المفاهيم البرمجية بطريقة تفاعلية.",
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;
  final bool isExpanded;

  const _FaqTile({
    required this.question,
    required this.answer,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          iconColor: AppColors.primaryColors,
          collapsedIconColor: AppColors.primaryColors,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Row(
            textDirection: TextDirection.rtl,
            children: [
              Image.asset(AssetsData.faq),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,

                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),

          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,

                style: const TextStyle(
                  color: Colors.grey,
                  height: 1.6,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
