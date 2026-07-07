import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/custom_drawer.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:roboo/features/app/courses/presentation/view/widgets/courses_filter_tabs_widget.dart';
import 'package:roboo/features/shared/topics/data/models/topic_model.dart';
import 'package:roboo/features/shared/topics/presentation/view-model/topics_cubit/topics_cubit.dart';

import '../../../home/presentation/view/widgets/course_list_item.dart';
import '../../../home/presentation/view/widgets/custom_app_bar.dart';

class CoursesScreen extends StatefulWidget {
  static const String routeName = "/courses";
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  int _selectedFilterIndex = 0;

  final List<Map<String, dynamic>> _courses = [
    {
      "title": "تعلّم البرمجة بلغة Java",
      "subtitle": "ابدأ رحلتك في عالم البرمجة الآن و تعلم معنا لغة java",
      "lectures": 45,
      "hours": 20,
      "location": "أونلاين",
      "isOnline": true,
      "isFav": true,
      "accentColor": AppColors.red,
      "categoryImage": AssetsData.programming,
      "badgeIcon": Icons.code,
    },
    {
      "title": "تعلم البرمجة بلغة Python",
      "subtitle": "هل أنت من محبي الابتكار و الابداع في التكنولوجيا...",
      "lectures": 20,
      "customMetadata": "18/10/2025",
      "location": "في المعهد",
      "isOnline": false,
      "isFav": false,
      "accentColor": const Color(0xFF64B5F6),
      "categoryImage": AssetsData.programming,
      "badgeIcon": Icons.terminal,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TopicsCubit(getit.get())..getTopics(),
      child: Scaffold(
        drawer: const CustomDrawer(),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const TopBarWidget(),
              const SizedBox(height: 24),
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
                      TopicsLoaded(:final topics) => _CoursesContent(
                        selectedFilterIndex: _selectedFilterIndex,
                        filters: _topicFilters(context, topics),
                        courses: _courses,
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

class _CoursesContent extends StatelessWidget {
  final int selectedFilterIndex;
  final List<Map<String, dynamic>> filters;
  final List<Map<String, dynamic>> courses;
  final ValueChanged<int> onFilterSelect;

  const _CoursesContent({
    required this.selectedFilterIndex,
    required this.filters,
    required this.courses,
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
          child: courses.isEmpty
              ? StatusDisplayWidget(message: "no_courses_available".tr(context))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return CourseListItem(
                      title: course['title'],
                      subtitle: course['subtitle'],
                      lectures: course['lectures'],
                      hours: course['hours'],
                      location: course['location'],
                      isOnline: course['isOnline'],
                      isFav: course['isFav'],
                      accentColor: course['accentColor'],
                      categoryImage: course['categoryImage'],
                      badgeIcon: course['badgeIcon'],
                      customMetadata: course['customMetadata'],
                      imagePlaceholder: const Center(
                        child: Icon(
                          Icons.coffee,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
