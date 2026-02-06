import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/custom_drawer.dart';
import 'package:roboo/core/utils/roboo_shapes.dart';
import 'package:roboo/features/app/home/presentation/view/widgets/category_3d_card.dart';
import 'package:roboo/features/app/home/presentation/view/widgets/course_list_item.dart';
import 'package:roboo/features/app/home/presentation/view/widgets/course_progress_card.dart';
import 'package:roboo/features/app/home/presentation/view/widgets/custom_app_bar.dart';
import 'package:roboo/features/app/home/presentation/view/widgets/header_welcome.dart';
import 'package:roboo/features/app/home/presentation/view/widgets/section_header_widget.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "/home";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const TopBarWidget(),
              const SizedBox(height: 24),

              // 1. Header & Categories 3D
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(height: 330),
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
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Category3DCard(
                                titleKey: "category_ai",

                                color: AppColors.aiCategoryColor,
                                shadowColor: AppColors.aiCategoryShadowColor,
                                image: AssetsData.ai,
                                height: 210,
                                shadowOffset: Offset(-5, 8),
                                shapeType: CardShapeType.rightSlope,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Category3DCard(
                                titleKey: "category_programming",
                                color: AppColors.programmingCategoryColor,
                                shadowColor:
                                    AppColors.programmingCategoryShadowColor,
                                image: AssetsData.programming,
                                height: 170,
                                shadowOffset: Offset(0, 8),
                                shapeType: CardShapeType.centerNotch,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Category3DCard(
                                titleKey: "category_robotics",
                                color: AppColors.roboticCategoryColor,
                                shadowColor:
                                    AppColors.roboticCategoryShadowColor,
                                image: AssetsData.robotic,
                                height: 210,
                                shadowOffset: Offset(5, 8),
                                shapeType: CardShapeType.leftSlope,
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
              SectionHeader(titleKey: "my_courses", onViewAll: () {}),

              CourseProgressCard(
                title: "تعلّم البرمجة بلغة Java",
                categoryImage: AssetsData.programming,
                progressPercentage: 65,
              ),

              // 3. Popular Courses Section
              SectionHeader(titleKey: "popular_courses", onViewAll: () {}),

              CourseListItem(
                title: "تعلّم البرمجة بلغة Java",
                subtitle:
                    "ابدأ رحلتك في عالم البرمجة الآن و تعلم معنا لغة java",
                lectures: 45,
                hours: 20,
                location: "online",
                accentColor: AppColors.programmingCategoryColor,
                categoryImage: AssetsData.programming,
                imagePlaceholder: const Icon(
                  Icons.coffee,
                  color: Colors.white,
                  size: 50,
                ),
                badgeIcon: Icons.terminal,
                isFav: true,
              ),

              CourseListItem(
                title: "دورة تعلّم روبوتات الليغو",
                subtitle: "ابتكر روبوتات من الليغو و شارك في مسابقة WRO",
                lectures: 20,
                customMetadata: "18/10/2025",
                location: "onsite",
                accentColor: AppColors.roboticCategoryColor,
                categoryImage: AssetsData.robotic,
                imagePlaceholder: const Icon(
                  Icons.smart_toy_outlined,
                  color: Colors.white,
                  size: 50,
                ),
                badgeIcon: Icons.star,
                isOnline: false,
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
