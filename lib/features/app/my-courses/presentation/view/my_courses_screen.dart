import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/features/app/course/presentation/view/course_details_screen_screen.dart';
import 'package:roboo/features/app/courses/presentation/view/widgets/courses_filter_tabs_widget.dart';
import 'package:roboo/features/app/home/presentation/view/widgets/course_progress_card.dart';
import 'package:roboo/features/app/my-courses/data/models/my_course_model.dart';
import 'package:roboo/features/app/my-courses/presentation/view-model/my_courses_cubit/my_courses_cubit.dart';
import 'package:roboo/features/shared/topics/data/models/topic_model.dart';

class MyCoursesScreen extends StatelessWidget {
  static const String routeName = '/my-courses';

  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MyCoursesCubit(getit.get(), getit.get())..getMyCoursesData(),
      child: Scaffold(
        appBar: CustomAppbar(title: "my_courses_title".tr(context)),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),

              Expanded(
                child: BlocBuilder<MyCoursesCubit, MyCoursesState>(
                  builder: (context, state) {
                    return switch (state) {
                      MyCoursesInitial() ||
                      MyCoursesLoading() => StatusDisplayWidget(
                        message: "wait".tr(context),
                        withAnimation: true,
                      ),
                      MyCoursesError(:final errorMsg) => StatusDisplayWidget(
                        message: errorMsg.tr(context),
                      ),
                      MyCoursesEmpty(:final topics, :final selectedIndex) =>
                        _MyCoursesContent(
                          selectedFilterIndex: selectedIndex,
                          filters: _topicFilters(context, topics),
                          courses: const [],
                        ),
                      MyCoursesLoaded(
                        :final topics,
                        :final courses,
                        :final selectedIndex,
                      ) =>
                        _MyCoursesContent(
                          selectedFilterIndex: selectedIndex,
                          filters: _topicFilters(context, topics),
                          courses: courses,
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

    return [
      {'label': 'all_topics', 'translateLabel': true},
      ...topics.map(
        (topic) => {
          'label': topic.nameFor(languageCode),
          'translateLabel': false,
        },
      ),
    ];
  }
}

class _MyCoursesContent extends StatelessWidget {
  final int selectedFilterIndex;
  final List<Map<String, dynamic>> filters;
  final List<MyCourseModel> courses;

  const _MyCoursesContent({
    required this.selectedFilterIndex,
    required this.filters,
    required this.courses,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CourseFilterTabs(
          selectedIndex: selectedFilterIndex,
          filters: filters,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          clipBehavior: Clip.none,
          onSelect: context.read<MyCoursesCubit>().selectTopic,
        ),

        const SizedBox(height: 8),

        Expanded(
          child: courses.isEmpty
              ? StatusDisplayWidget(message: "no_active_courses".tr(context))
              : RefreshIndicator(
                  onRefresh: context.read<MyCoursesCubit>().getMyCoursesData,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      final languageCode = Localizations.localeOf(
                        context,
                      ).languageCode;

                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context,
                          CourseDetailsScreen.routeName,
                          arguments: course.id == null
                              ? null
                              : CourseDetailsArgs(courseId: course.id!),
                        ),
                        child: CourseProgressCard(
                          title: course.titleFor(languageCode),
                          categoryImage: course.topic?.imageUrl ?? '',
                          categoryColor: course.topic?.displayColor,
                          imageUrl: course.imageUrl,
                          courseId: course.id,
                          isFav: course.isFavorite,
                          progressPercentage: course.progress.percentage
                              .round(),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
