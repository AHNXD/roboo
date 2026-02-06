import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/features/app/courses/presentation/view/widgets/courses_filter_tabs_widget.dart';
import 'package:roboo/features/app/home/presentation/view/widgets/course_progress_card.dart';

class MyCoursesScreen extends StatefulWidget {
  static const String routeName = '/my-courses';
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  int _selectedFilterIndex = 0;

  // Filters using Localization Keys
  final List<Map<String, dynamic>> _filters = [
    {'label': 'filter_programming', 'icon': AssetsData.programming},
    {'label': 'filter_robotics', 'icon': AssetsData.robotic},
    {'label': 'filter_ai', 'icon': AssetsData.ai},
  ];

  // Mock Data
  // Toggle this list to [] to test the Empty State
  final List<Map<String, dynamic>> _courses = [
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
      appBar: CustomAppbar(title: "my_courses_title".tr(context)),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // 1. Reusable Filter Tabs
            CourseFilterTabs(
              selectedIndex: _selectedFilterIndex,
              filters: _filters,
              onSelect: (index) {
                setState(() => _selectedFilterIndex = index);
              },
            ),

            const SizedBox(height: 8),

            // 2. List or Empty State
            Expanded(
              child: _courses.isEmpty
                  ? StatusDisplayWidget(
                      message: "no_active_courses".tr(context),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemCount: _courses.length,
                      itemBuilder: (context, index) {
                        final course = _courses[index];
                        return CourseProgressCard(
                          title: course['title'],
                          categoryImage: course['categoryImage'],
                          progressPercentage: (course['progress'] as num)
                              .toInt(),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
