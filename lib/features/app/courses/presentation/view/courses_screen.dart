import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roboo/core/navigation/main_nav_cubit.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:roboo/core/widgets/custom_drawer.dart';
import 'package:roboo/core/widgets/refreshable_status.dart';
import 'package:roboo/core/widgets/load_more_listener.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/features/app/courses/data/models/course_model.dart';
import 'package:roboo/features/app/courses/presentation/view-model/courses_cubit/courses_cubit.dart';
import 'package:roboo/features/app/courses/presentation/view/widgets/courses_filter_tabs_widget.dart';
import 'package:roboo/features/shared/topics/data/models/topic_model.dart';

import '../../../home/presentation/view/widgets/course_list_item.dart';
import '../../../home/presentation/view/widgets/custom_app_bar.dart';

class CoursesScreen extends StatelessWidget {
  static const String routeName = "/courses";
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CoursesCubit(getit.get(), getit.get())..getCoursesData(),
      // The home screen's fixed shapes ask for a topic by slug; this tab lives
      // in an IndexedStack, so it is already built and just needs to react.
      child: BlocListener<MainNavCubit, MainNavState>(
        bloc: getit.get<MainNavCubit>(),
        listenWhen: (previous, current) =>
            current.pendingTopicSlug != null &&
            current.pendingTopicSlug != previous.pendingTopicSlug,
        listener: (context, state) {
          final slug = state.pendingTopicSlug;
          if (slug == null) return;

          context.read<CoursesCubit>().selectTopicBySlug(slug);
          // Consumed, so coming back to this tab later does not re-apply it.
          getit.get<MainNavCubit>().clearPendingTopic();
        },
        child: _buildScaffold(context),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const TopBarWidget(),
            const SizedBox(height: 24),
            Expanded(
              child: BlocBuilder<CoursesCubit, CoursesState>(
                builder: (context, state) {
                  return switch (state) {
                    CoursesInitial() || CoursesLoading() => StatusDisplayWidget(
                      message: "wait".tr(context),
                      withAnimation: true,
                    ),
                    CoursesError(:final errorMsg) => RefreshableStatus(
                      onRefresh: context.read<CoursesCubit>().getCoursesData,
                      child: StatusDisplayWidget(message: errorMsg.tr(context)),
                    ),
                    CoursesContentLoading(
                      :final topics,
                      :final selectedIndex,
                    ) =>
                      _CoursesContent(
                        selectedFilterIndex: selectedIndex,
                        filters: _topicFilters(context, topics),
                        courses: const [],
                        isLoading: true,
                      ),
                    CoursesContentError(
                      :final topics,
                      :final selectedIndex,
                      :final errorMsg,
                    ) =>
                      _CoursesContent(
                        selectedFilterIndex: selectedIndex,
                        filters: _topicFilters(context, topics),
                        courses: const [],
                        errorMessage: errorMsg.tr(context),
                      ),
                    CoursesEmpty(:final topics, :final selectedIndex) =>
                      _CoursesContent(
                        selectedFilterIndex: selectedIndex,
                        filters: _topicFilters(context, topics),
                        courses: const [],
                      ),
                    CoursesLoaded(
                      :final topics,
                      :final courses,
                      :final selectedIndex,
                      :final hasMore,
                      :final isLoadingMore,
                    ) =>
                      _CoursesContent(
                        selectedFilterIndex: selectedIndex,
                        filters: _topicFilters(context, topics),
                        courses: courses,
                        hasMore: hasMore,
                        isLoadingMore: isLoadingMore,
                      ),
                  };
                },
              ),
            ),
          ],
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
          // Not every topic has an icon uploaded; the chip drops it silently.
          'icon': topic.imageUrl,
        },
      ),
    ];
  }
}

class _CoursesContent extends StatelessWidget {
  final int selectedFilterIndex;
  final List<Map<String, dynamic>> filters;
  final List<CourseModel> courses;
  final bool isLoading;
  final bool hasMore;
  final bool isLoadingMore;
  final String? errorMessage;

  const _CoursesContent({
    required this.selectedFilterIndex,
    required this.filters,
    required this.courses,
    this.isLoading = false,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.errorMessage,
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
          onSelect: context.read<CoursesCubit>().selectTopic,
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildCoursesContent(context)),
      ],
    );
  }

  Widget _buildCoursesContent(BuildContext context) {
    if (isLoading) {
      return StatusDisplayWidget(
        message: "wait".tr(context),
        withAnimation: true,
      );
    }

    final message = errorMessage;
    if (message != null) {
      return StatusDisplayWidget(message: message);
    }

    if (courses.isEmpty) {
      return StatusDisplayWidget(message: "no_courses_available".tr(context));
    }

    final languageCode = Localizations.localeOf(context).languageCode;
    return LoadMoreListener(
      canLoadMore: hasMore && !isLoadingMore,
      onLoadMore: context.read<CoursesCubit>().loadMoreCourses,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        physics: const AlwaysScrollableScrollPhysics(),
        // One extra row at the end for the "loading more" spinner.
        itemCount: courses.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= courses.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryColors,
                ),
              ),
            );
          }

          final course = courses[index];
          return CourseListItem(
            courseId: course.id,
            title: course.titleFor(languageCode),
            subtitle: course.descriptionFor(languageCode),
            lectures: course.lessonsCount ?? course.sessionsCount,
            hours: course.durationHours,
            customMetadata: course.startDate ?? '',
            location: course.isOnline
                ? "online".tr(context)
                : "in_institute".tr(context),
            isOnline: course.isOnline,
            isFav: course.isFavorite,
            accentColor: AppColors.primaryColors,
            categoryImage: course.topic?.imageUrl ?? '',
            categoryColor: course.topic?.displayColor,
            badgeIcon: course.isOnline ? Icons.language : Icons.location_on,
            imageUrl: course.imageUrl,
            imagePlaceholder: const Center(
              child: Icon(Icons.school, size: 50, color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}
