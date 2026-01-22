import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/features/app/home/presentation/view/widgets/category_3d_card.dart';
import 'package:roboo/features/app/home/presentation/view/widgets/course_list_item.dart';
import 'package:roboo/features/app/home/presentation/view/widgets/custom_app_bar.dart';
import 'package:roboo/features/app/home/presentation/view/widgets/header_welcome.dart';

import '../../../../../core/utils/roboo_shapes.dart';

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
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const TopBarWidget(),
              SizedBox(height: 8),

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
                          children: const [
                            Expanded(
                              child: Category3DCard(
                                title: "الذكاء\nالاصطناعي",
                                color: Color(0xFF9E7BB5),
                                shadowColor: Color(0xFF705285),
                                image: AssetsData.ai,
                                height: 210,
                                shadowOffset: Offset(-5, 8),
                                shapeType: CardShapeType.rightSlope,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Category3DCard(
                                title: "البرمجة",
                                color: Color(0xFF7CC576),
                                shadowColor: Color(0xFF559150),
                                image: AssetsData.programming,
                                height: 170,
                                shadowOffset: Offset(0, 8),
                                shapeType: CardShapeType.centerNotch,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Category3DCard(
                                title: "الروبوتيك",
                                color: Color(0xFFD4AF57),
                                shadowColor: Color(0xFFA68535),
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

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "الدورات الأكثر طلباً",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "عرض الكل",
                        style: TextStyle(color: Color(0xFF80B5B6)),
                      ),
                    ),
                  ],
                ),
              ),

              CourseListItem(
                title: "تعلّم البرمجة بلغة Java",
                subtitle:
                    "ابدأ رحلتك في عالم البرمجة الآن و تعلم معنا لغة java",
                lectures: 45,
                hours: 20,
                location: "online",
                accentColor: AppColors.programmingCategoryColor,
                categoryImage: AssetsData.programming,
                imagePlaceholder: Icon(
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
                imagePlaceholder: Icon(
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
