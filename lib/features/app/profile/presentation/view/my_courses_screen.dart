import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/features/app/home/presentation/view/widgets/course_progress_card.dart';

class MyCoursesScreen extends StatefulWidget {
    static const String routeName = '/my-courses';
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  int _selectedFilterIndex = 0;

  // Filters Data
  final List<Map<String, dynamic>> _filters = [
    {'label': 'البرمجة', 'icon': AssetsData.programming},
    {'label': 'الروبوتيك', 'icon': AssetsData.robotic},
    {'label': 'الذكاء الاصطناعي', 'icon': AssetsData.ai},
  ];

  final List<Map<String, dynamic>> _courses = [
    // Uncomment to test populated state:
    {
      'title': 'تعلّم البرمجة بلغة Java',
      'categoryImage': AssetsData.programming,
      'progress': 75,
      'image': AssetsData.logo,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "دوراتي"),
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
              child: _courses.isEmpty
                  ? _buildEmptyState()
                  : _buildCoursesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(AssetsData.flyingRoboo),
        const SizedBox(height: 30),
        const Text(
          "لا يوجد دورات تتعلمها حالياً",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildCoursesList() {
    return ListView.builder(
      itemCount: _courses.length,
      itemBuilder: (context, index) {
        final course = _courses[index];
        return CourseProgressCard(
          title: course['title'],
          categoryImage: course['categoryImage'],
          progressPercentage: course['progress'],
        );
      },
    );
  }
}
