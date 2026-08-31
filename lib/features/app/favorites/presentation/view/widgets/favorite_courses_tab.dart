import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:roboo/core/widgets/load_more_listener.dart';
import 'package:roboo/core/widgets/refreshable_status.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/features/app/courses/presentation/view-model/course_favorites_cubit/course_favorites_cubit.dart';
import 'package:roboo/features/app/home/presentation/view/widgets/course_list_item.dart';

/// The courses half of the favourites screen. Reads the same app-wide cubit the
/// hearts elsewhere write to, so un-favouriting here or on the courses list
/// stays consistent either way.
class FavoriteCoursesTab extends StatelessWidget {
  const FavoriteCoursesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesCubit = getit<CourseFavoritesCubit>();

    return BlocBuilder<CourseFavoritesCubit, CourseFavoritesState>(
      bloc: favoritesCubit,
      builder: (context, state) {
        if (state.isLoadingList && state.courses.isEmpty) {
          return StatusDisplayWidget(
            message: "wait".tr(context),
            withAnimation: true,
          );
        }

        final errorMsg = state.listErrorMsg;
        if (errorMsg != null && state.courses.isEmpty) {
          return RefreshableStatus(
            onRefresh: favoritesCubit.loadFavoriteCourses,
            child: StatusDisplayWidget(message: errorMsg.tr(context)),
          );
        }

        if (state.courses.isEmpty) {
          return RefreshableStatus(
            onRefresh: favoritesCubit.loadFavoriteCourses,
            child: StatusDisplayWidget(
              message: "no_favorite_courses".tr(context),
            ),
          );
        }

        final languageCode = Localizations.localeOf(context).languageCode;

        return RefreshIndicator(
          onRefresh: favoritesCubit.loadFavoriteCourses,
          child: LoadMoreListener(
            canLoadMore: state.hasMore && !state.isLoadingMore,
            onLoadMore: favoritesCubit.loadMoreFavoriteCourses,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              physics: const AlwaysScrollableScrollPhysics(),
              // One extra row for the "loading more" spinner.
              itemCount: state.courses.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.courses.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColors,
                      ),
                    ),
                  );
                }

                final course = state.courses[index];

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
                  badgeIcon: course.isOnline
                      ? Icons.language
                      : Icons.location_on,
                  imageUrl: course.imageUrl,
                  imagePlaceholder: const Center(
                    child: Icon(Icons.school, size: 50, color: Colors.white),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
