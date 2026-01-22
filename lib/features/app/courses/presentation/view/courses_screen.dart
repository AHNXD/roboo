import 'package:flutter/material.dart';

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
    {"label": "البرمجة", "icon": Icons.code},
    {"label": "الروبوتيك", "icon": Icons.smart_toy_outlined},
    {"label": "الذكاء الاصطناعي", "icon": Icons.psychology},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. Top Bar Section ---
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
              child:
                  TopBarWidget(), // Ensure this widget exists and is imported
            ),

            const SizedBox(height: 15),

            // --- 2. Filter Chips Section ---
            SizedBox(
              height: 45,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (c, i) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final bool isSelected = index == _selectedFilterIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilterIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF5CA4A5)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF5CA4A5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _filters[index]['label'],
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF5CA4A5),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _filters[index]['icon'],
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF5CA4A5),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

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
