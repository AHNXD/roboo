import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/course_model.dart';
import '../../../data/repos/courses_repo.dart';
import '../../../../../../core/models/pagination_model.dart';
import '../../../../../../core/utils/safe_emit.dart';

part 'course_favorites_state.dart';

/// App-wide, because a course's heart appears on the list, the home preview and
/// the details screen at once. Every course payload already carries
/// `is_favorite`; this only remembers the toggles made since, so the icon does
/// not flip back when a screen rebuilds from a cached response.
class CourseFavoritesCubit extends Cubit<CourseFavoritesState>
    with SafeEmit<CourseFavoritesState> {
  final CoursesRepo _coursesRepo;

  CourseFavoritesCubit(this._coursesRepo) : super(const CourseFavoritesState());

  PaginationModel _pagination = PaginationModel.single;
  bool _isLoadingMore = false;

  Future<void> loadFavoriteCourses() async {
    safeEmit(state.copyWith(isLoadingList: true, clearListError: true));

    final result = await _coursesRepo.getFavoriteCourses();
    result.fold(
      (failure) => safeEmit(
        state.copyWith(isLoadingList: false, listErrorMsg: failure.message),
      ),
      (page) {
        _pagination = page.pagination;
        safeEmit(
          state.copyWith(
            courses: page.items,
            isLoadingList: false,
            hasMore: page.hasMore,
            clearListError: true,
          ),
        );
      },
    );
  }

  /// Appends the next page of favourites. A failure leaves the list intact.
  Future<void> loadMoreFavoriteCourses() async {
    if (_isLoadingMore || !_pagination.hasMore) return;

    _isLoadingMore = true;
    safeEmit(state.copyWith(isLoadingMore: true));

    final result = await _coursesRepo.getFavoriteCourses(
      page: _pagination.nextPage,
    );

    _isLoadingMore = false;

    result.fold((_) => safeEmit(state.copyWith(isLoadingMore: false)), (page) {
      _pagination = page.pagination;
      safeEmit(
        state.copyWith(
          courses: [...state.courses, ...page.items],
          isLoadingMore: false,
          hasMore: page.hasMore,
        ),
      );
    });
  }

  Future<void> toggleFavorite(int? courseId) async {
    if (courseId == null) return;

    safeEmit(state.copyWith(pendingCourseId: courseId, clearError: true));

    final result = await _coursesRepo.toggleFavorite(courseId: courseId);
    result.fold(
      (failure) => safeEmit(
        state.copyWith(
          errorMsg: failure.message,
          errorCourseId: courseId,
          clearPending: true,
        ),
      ),
      (toggle) {
        final overrides = Map<int, bool>.from(state.overrides);
        for (final id in toggle.attached) {
          overrides[id] = true;
        }
        for (final id in toggle.detached) {
          overrides[id] = false;
        }

        // Un-favouriting from the favourites list should drop the row rather
        // than leave a course there with an empty heart.
        final detached = toggle.detached.toSet();
        final courses = detached.isEmpty
            ? state.courses
            : state.courses
                  .where((course) => !detached.contains(course.id))
                  .toList();

        safeEmit(
          state.copyWith(
            courses: courses,
            overrides: overrides,
            clearPending: true,
            clearError: true,
          ),
        );
      },
    );
  }
}
