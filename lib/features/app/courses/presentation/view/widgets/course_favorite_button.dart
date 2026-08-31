import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/utils/functions.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:roboo/core/widgets/favorite_icon_widget.dart';
import 'package:roboo/features/app/courses/presentation/view-model/course_favorites_cubit/course_favorites_cubit.dart';

/// The heart on a course card. Reads the app-wide toggle cubit directly rather
/// than needing a provider above every list, and falls back to the
/// `is_favorite` the API sent with the course.
class CourseFavoriteButton extends StatelessWidget {
  final int? courseId;
  final bool initialIsFavorite;

  const CourseFavoriteButton({
    super.key,
    required this.courseId,
    this.initialIsFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final favoritesCubit = getit.get<CourseFavoritesCubit>();

    return BlocConsumer<CourseFavoritesCubit, CourseFavoritesState>(
      bloc: favoritesCubit,
      listenWhen: (previous, current) =>
          current.errorCourseId == courseId &&
          current.errorMsg != null &&
          current.errorMsg != previous.errorMsg,
      listener: (context, state) {
        messages(context, state.errorMsg!.tr(context), AppColors.red);
      },
      buildWhen: (previous, current) =>
          previous.isFavorite(courseId, fallback: initialIsFavorite) !=
              current.isFavorite(courseId, fallback: initialIsFavorite) ||
          previous.isPending(courseId) != current.isPending(courseId),
      builder: (context, state) {
        return FavIcon(
          isFav: state.isFavorite(courseId, fallback: initialIsFavorite),
          isLoading: state.isPending(courseId),
          onTap: courseId == null
              ? null
              : () => favoritesCubit.toggleFavorite(courseId),
        );
      },
    );
  }
}
