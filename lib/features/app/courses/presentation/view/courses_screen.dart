import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/custom_drawer.dart';

// Ensure this path matches your actual project structure
import '../../../../../core/utils/assets_data.dart';
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

  final List<Map<String, dynamic>> _filters = [
    {"label": "البرمجة", "icon": AssetsData.programming},
    {"label": "الروبوتيك", "icon": AssetsData.robotic},
    {"label": "الذكاء الاصطناعي", "icon": AssetsData.ai},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // --- 1. Top Bar Section ---
            const TopBarWidget(),
            const SizedBox(height: 24),

            // --- 2. Filter Chips Section ---
            SizedBox(
              height: 60,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),

                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (c, i) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final bool isSelected = index == _selectedFilterIndex;
                  const Color themeColor = AppColors.primaryColors;

                  return Padding(
                    padding: EdgeInsetsGeometry.symmetric(vertical: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilterIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 24),

                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? themeColor : Colors.white,
                          borderRadius: BorderRadius.circular(
                            16,
                          ), // High radius makes it a perfect capsule
                          border: Border.all(color: themeColor, width: 1.5),
                          boxShadow: [
                            // This is the specific shadow configuration
                            BoxShadow(
                              color: themeColor.withOpacity(
                                0.5,
                              ), // Soft teal shadow
                              blurRadius: 4, // Softens the edge
                              spreadRadius: 0,
                              offset: const Offset(0, 4), // Pushes shadow down
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              _filters[index]['icon'],
                              width: 24,
                              height: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              _filters[index]['label'],
                              style: GoogleFonts.cairo(
                                color: isSelected ? Colors.white : themeColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // --- 3. Course List Section ---
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  CourseListItem(
                    title: "تعلّم البرمجة بلغة Java",
                    subtitle:
                        "ابدأ رحلتك في عالم البرمجة الآن و تعلم معنا لغة java",
                    lectures: 45,
                    hours: 20,
                    location: "أونلاين",
                    isOnline: true,
                    isFav: true, // Shows gray/filled heart based on logic
                    accentColor: const Color(0xFFE57373), // Reddish
                    // Small badge icon path
                    categoryImage: AssetsData.programming,
                    badgeIcon: Icons.code, // (Pass to satisfy constructor)
                    // Main big icon/image
                    imagePlaceholder: const Center(
                      child: Icon(Icons.coffee, size: 50, color: Colors.white),
                    ),
                  ),

                  // ITEM 2: Python Course
                  CourseListItem(
                    title: "تعلم البرمجة بلغة Python",
                    subtitle:
                        "هل أنت من محبي الابتكار و الابداع في التكنولوجيا...",
                    lectures: 20,
                    // Custom date instead of hours
                    customMetadata: "18/10/2025",
                    location: "في المعهد",
                    isOnline: false,
                    isFav: false,
                    accentColor: const Color(0xFF64B5F6), // Blueish

                    categoryImage: AssetsData.programming,
                    badgeIcon: Icons.terminal,

                    imagePlaceholder: const Center(
                      child: Icon(Icons.code, size: 50, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
