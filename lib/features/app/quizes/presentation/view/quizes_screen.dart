import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/features/app/quizes/presentation/view/quiz_screen.dart';

class QuizesScreen extends StatefulWidget {
  static const String routeName = '/quizes';

  const QuizesScreen({super.key});

  @override
  State<QuizesScreen> createState() => _QuizesScreenState();
}

class _QuizesScreenState extends State<QuizesScreen> {
  int _selectedFilterIndex = 0;

  // Filters Data
  final List<Map<String, dynamic>> _filters = [
    {'label': 'البرمجة', 'icon': AssetsData.programming},
    {'label': 'الروبوتيك', 'icon': AssetsData.robotic},
    {'label': 'الذكاء الاصطناعي', 'icon': AssetsData.ai},
  ];

  // Mock Data for Tests
  final List<TestItemModel> _tests = [
    TestItemModel(
      title: "اختبار Java",
      questions: 40,
      duration: 20,
      points: 50,
    ),
    TestItemModel(
      title: "اختبار Python",
      questions: 40,
      duration: 20,
      points: 70,
    ),
    TestItemModel(title: "اختبار C++", questions: 40, duration: 20, points: 50),
    TestItemModel(
      title: "اختبار Javascript",
      questions: 40,
      duration: 20,
      points: 50,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "الاختبارات"),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 60,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),

                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (c, i) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final bool isSelected = index == _selectedFilterIndex;
                  const Color themeColor = AppColors.primaryColors;

                  return Padding(
                    padding: EdgeInsetsGeometry.symmetric(vertical: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilterIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 24),

                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? themeColor : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: themeColor, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: themeColor.withValues(alpha: 0.5),
                              blurRadius: 4,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              _filters[index]['icon'],
                              width: 24,
                              height: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              _filters[index]['label'],
                              style: GoogleFonts.cairo(
                                color: isSelected ? Colors.white : themeColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                itemCount: _tests.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 24),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, QuizScreen.routeName);
                    },
                    child: _buildTestRow(_tests[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestRow(TestItemModel test) {
    return SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildSkewedIcon(),

          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                test.title,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${test.questions} سؤال",
                    style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.help_outline, size: 14, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    "${test.duration} دقيقة",
                    style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                ],
              ),
            ],
          ),
          const Spacer(),

          Text(
            "${test.points}+ نقطة",
            style: GoogleFonts.cairo(
              color: const Color(0xFF7FB5B7), // Light Teal
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkewedIcon() {
    const double skewAmount = -0.25;

    return Transform(
      transform: Matrix4.skewX(skewAmount),
      alignment: Alignment.center,
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          color: const Color(0xFF7FB5B7),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Transform(
          transform: Matrix4.skewX(-skewAmount),
          alignment: Alignment.center,
          child: const Center(
            child: Icon(
              Icons.description_outlined, // Document/Test icon
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}

class TestItemModel {
  final String title;
  final int questions;
  final int duration;
  final int points;

  TestItemModel({
    required this.title,
    required this.questions,
    required this.duration,
    required this.points,
  });
}
