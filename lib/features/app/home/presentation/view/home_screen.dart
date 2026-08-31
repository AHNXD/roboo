import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/navigation/main_nav_cubit.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/custom_drawer.dart';
import 'package:roboo/core/utils/roboo_shapes.dart';
import 'package:roboo/features/app/home/presentation/view/widgets/category_3d_card.dart';
import 'package:roboo/features/app/home/presentation/view/widgets/course_list_item.dart';
import 'package:roboo/features/app/home/presentation/view/widgets/course_progress_card.dart';
import 'package:roboo/features/app/home/presentation/view/widgets/custom_app_bar.dart';
import 'package:roboo/features/app/home/presentation/view/widgets/header_welcome.dart';
import 'package:roboo/features/app/home/presentation/view/widgets/section_header_widget.dart';
import 'package:roboo/features/app/home/presentation/view-model/home_cubit/home_cubit.dart';
import 'package:roboo/features/app/course/presentation/view/course_details_screen_screen.dart';
import 'package:roboo/features/app/my-courses/presentation/view/my_courses_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "/home";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final TextDirection currentDirection = Directionality.of(context);
    return BlocProvider(
      create: (_) => HomeCubit(getit.get(), getit.get())..getHomeData(),
      // Builder so the scaffold gets a context *below* the provider; pull-to-
      // refresh reads the cubit from it.
      child: Builder(
        builder: (context) => _buildScaffold(context, currentDirection),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, TextDirection currentDirection) {
    return Scaffold(
      drawer: const CustomDrawer(),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => _refresh(context),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const TopBarWidget(),
                const SizedBox(height: 24),

                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(height: 305),
                    const Positioned(
                      top: -16,
                      left: 0,
                      right: 0,
                      child: CustomHeaderBanner(),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Category3DCard(
                                  titleKey: "category_ai",
                                  onTap: () => getit
                                      .get<MainNavCubit>()
                                      .openTopic('artificial-intelligence'),

                                  color: AppColors.aiCategoryColor,
                                  shadowColor: AppColors.aiCategoryShadowColor,
                                  image: AssetsData.ai,
                                  height: 190,
                                  shadowOffset: Offset(-5, 8),
                                  shapeType:
                                      currentDirection == TextDirection.ltr
                                      ? CardShapeType.leftSlope
                                      : CardShapeType.rightSlope,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Category3DCard(
                                  titleKey: "category_programming",
                                  onTap: () => getit
                                      .get<MainNavCubit>()
                                      .openTopic('programming'),
                                  color: AppColors.programmingCategoryColor,
                                  shadowColor:
                                      AppColors.programmingCategoryShadowColor,
                                  image: AssetsData.programming,
                                  height: 160,
                                  shadowOffset: Offset(0, 8),
                                  shapeType: CardShapeType.centerNotch,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Category3DCard(
                                  titleKey: "category_robotics",
                                  onTap: () => getit
                                      .get<MainNavCubit>()
                                      .openTopic('robotics'),
                                  color: AppColors.roboticCategoryColor,
                                  shadowColor:
                                      AppColors.roboticCategoryShadowColor,
                                  image: AssetsData.robotic,
                                  height: 190,
                                  shadowOffset: Offset(5, 8),
                                  shapeType:
                                      currentDirection == TextDirection.ltr
                                      ? CardShapeType.rightSlope
                                      : CardShapeType.leftSlope,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // 2. My Courses Section
                SectionHeader(
                  titleKey: "my_courses",
                  onViewAll: () =>
                      Navigator.pushNamed(context, MyCoursesScreen.routeName),
                ),

                BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) {
                    if (state is! HomeLoaded) return const SizedBox.shrink();

                    if (state.myCourses.isEmpty) {
                      return _HomeMessage(
                        message: "no_active_courses".tr(context),
                      );
                    }

                    final languageCode = Localizations.localeOf(
                      context,
                    ).languageCode;

                    return Column(
                      children: state.myCourses.map((course) {
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
                      }).toList(),
                    );
                  },
                ),

                // 3. Popular Courses Section
                SectionHeader(
                  titleKey: "popular_courses",
                  // Courses is a bottom-nav tab: switch to it rather than
                  // pushing a route that would cover the navigation bar.
                  onViewAll: () =>
                      getit.get<MainNavCubit>().goTo(MainTab.courses),
                ),

                BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) {
                    return switch (state) {
                      HomeInitial() ||
                      HomeLoading() => const _CoursesPlaceholder(),
                      HomeError(:final errorMsg) => _HomeMessage(
                        message: errorMsg.tr(context),
                      ),
                      HomeEmpty() => _HomeMessage(
                        message: "no_courses_available".tr(context),
                      ),
                      HomeLoaded(:final courses) => Column(
                        children: courses.map((course) {
                          final languageCode = Localizations.localeOf(
                            context,
                          ).languageCode;

                          return CourseListItem(
                            courseId: course.id,
                            title: course.titleFor(languageCode),
                            subtitle: course.descriptionFor(languageCode),
                            lectures:
                                course.lessonsCount ?? course.sessionsCount,
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
                              child: Icon(
                                Icons.school,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    };
                  },
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refresh(BuildContext context) =>
      context.read<HomeCubit>().getHomeData();
}

/// Course-shaped placeholders, so the home page does not jump when the
/// courses arrive. Grey rather than the app's dark shimmer palette, which is
/// meant for dark surfaces.
class _CoursesPlaceholder extends StatelessWidget {
  const _CoursesPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        2,
        (_) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 130,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeMessage extends StatelessWidget {
  final String message;

  const _HomeMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
