import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/features/app/courses/presentation/view/widgets/courses_filter_tabs_widget.dart';
import 'package:roboo/features/app/quizes/presentation/view/quiz_screen.dart';
import 'package:roboo/features/app/quizes/presentation/view/widgets/quize_list_item_widget.dart';
import 'package:roboo/features/shared/topics/data/models/topic_model.dart';
import 'package:roboo/features/shared/topics/presentation/view-model/topics_cubit/topics_cubit.dart';

class QuizesScreen extends StatefulWidget {
  static const String routeName = '/quizes';

  const QuizesScreen({super.key});

  @override
  State<QuizesScreen> createState() => _QuizesScreenState();
}

class _QuizesScreenState extends State<QuizesScreen> {
  int _selectedFilterIndex = 0;

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
    return BlocProvider(
      create: (_) => TopicsCubit(getit.get())..getTopics(),
      child: Scaffold(
        appBar: CustomAppbar(title: "quizzes_title".tr(context)),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Expanded(
                child: BlocBuilder<TopicsCubit, TopicsState>(
                  builder: (context, state) {
                    return switch (state) {
                      TopicsInitial() || TopicsLoading() => StatusDisplayWidget(
                        message: "wait".tr(context),
                        withAnimation: true,
                      ),
                      TopicsEmpty() => StatusDisplayWidget(
                        message: "no_topics_available".tr(context),
                      ),
                      TopicsError(:final errorMsg) => StatusDisplayWidget(
                        message: errorMsg.tr(context),
                      ),
                      TopicsLoaded(:final topics) => _QuizzesContent(
                        selectedFilterIndex: _selectedFilterIndex,
                        filters: _topicFilters(context, topics),
                        tests: _tests,
                        onFilterSelect: (index) {
                          setState(() => _selectedFilterIndex = index);
                        },
                      ),
                    };
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _topicFilters(
    BuildContext context,
    List<TopicModel> topics,
  ) {
    final languageCode = Localizations.localeOf(context).languageCode;

    return topics
        .map(
          (topic) => {
            'label': topic.nameFor(languageCode),
            'translateLabel': false,
          },
        )
        .toList();
  }
}

class _QuizzesContent extends StatelessWidget {
  final int selectedFilterIndex;
  final List<Map<String, dynamic>> filters;
  final List<Map<String, dynamic>> tests;
  final ValueChanged<int> onFilterSelect;

  const _QuizzesContent({
    required this.selectedFilterIndex,
    required this.filters,
    required this.tests,
    required this.onFilterSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CourseFilterTabs(
          selectedIndex: selectedFilterIndex,
          filters: filters,
          onSelect: onFilterSelect,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: tests.isEmpty
              ? StatusDisplayWidget(message: "no_quizzes_available".tr(context))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  itemCount: tests.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 24),
                  itemBuilder: (context, index) {
                    final test = tests[index];
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
    );
  }
}
