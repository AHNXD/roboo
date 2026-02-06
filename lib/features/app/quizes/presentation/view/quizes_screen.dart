import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/features/app/courses/presentation/view/widgets/courses_filter_tabs_widget.dart';
import 'package:roboo/features/app/quizes/presentation/view/quiz_screen.dart';
import 'package:roboo/features/app/quizes/presentation/view/widgets/quize_list_item_widget.dart';

class QuizesScreen extends StatefulWidget {
  static const String routeName = '/quizes';

  const QuizesScreen({super.key});

  @override
  State<QuizesScreen> createState() => _QuizesScreenState();
}

class _QuizesScreenState extends State<QuizesScreen> {
  int _selectedFilterIndex = 0;

  // Filters using Localization Keys
  final List<Map<String, dynamic>> _filters = [
    {'label': 'filter_programming', 'icon': AssetsData.programming},
    {'label': 'filter_robotics', 'icon': AssetsData.robotic},
    {'label': 'filter_ai', 'icon': AssetsData.ai},
  ];

  // Mock Data (Model can be moved to data layer)
  final List<Map<String, dynamic>> _tests = [
    {'title': "اختبار Java", 'questions': 40, 'duration': 20, 'points': 50},
    {'title': "اختبار Python", 'questions': 40, 'duration': 20, 'points': 70},
    {'title': "اختبار C++", 'questions': 40, 'duration': 20, 'points': 50},
    {
      'title': "اختبار Javascript",
      'questions': 40,
      'duration': 20,
      'points': 50,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "quizzes_title".tr(context)),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // 1. Filters
            CourseFilterTabs(
              selectedIndex: _selectedFilterIndex,
              filters: _filters,
              onSelect: (index) => setState(() => _selectedFilterIndex = index),
            ),

            const SizedBox(height: 8),

            // 2. List or Empty State
            Expanded(
              child: _tests.isEmpty
                  ? StatusDisplayWidget(
                      message: "no_quizzes_available".tr(context),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      itemCount: _tests.length,
                      separatorBuilder: (c, i) => const SizedBox(height: 24),
                      itemBuilder: (context, index) {
                        final test = _tests[index];
                        return QuizListItem(
                          title: test['title'],
                          questions: test['questions'],
                          duration: test['duration'],
                          points: test['points'],
                          onTap: () {
                            Navigator.pushNamed(context, QuizScreen.routeName);
                          },
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
