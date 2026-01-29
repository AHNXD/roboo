import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/features/app/home/presentation/view/widgets/custom_app_bar.dart';

import '../../../../../core/utils/colors.dart';
import '../../../../../core/widgets/custom_drawer.dart';
import '../../../product-details/presentation/view/product_details_screen.dart';
import 'widgets/product_card_widget.dart';

class StoreScreen extends StatefulWidget {
  static const String routeName = "/store";
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  int _selectedFilterIndex = 0;

  final List _filters = ["الكل", "الروبوتات", "معدات ليغو", "اكواد مصدرية"];

  final List<Map<String, String>> products = [
    {'title': 'عدة ليغو', 'price': '100\$', 'image': AssetsData.legoKit},
    {
      'title': 'كود مصدري للنظام...',
      'price': '2500\$',
      'image': AssetsData.sourceCode,
    },
    {'title': 'روبوت تعليمي', 'price': '150\$', 'image': AssetsData.robot},
    {'title': 'حساسات متقدمة', 'price': '45\$', 'image': AssetsData.ardRobot},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            TopBarWidget(),
            SizedBox(height: 24),
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
                        child: Text(
                          _filters[index],
                          style: GoogleFonts.cairo(
                            color: isSelected ? Colors.white : themeColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl, // Ensure Arabic Layout
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 items per row
                    crossAxisSpacing: 15, // Horizontal space between cards
                    mainAxisSpacing: 15, // Vertical space between cards
                    childAspectRatio:
                        0.65, // TWEAK THIS: Controls height vs width ratio
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return ProductCard(
                      title: products[index]['title']!,
                      price: products[index]['price']!,
                      imagePath: products[index]['image']!,
                      onTap: () {
                        // NAVIGATE TO DETAILS SCREEN
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailsScreen(
                              title: products[index]['title']!,
                              price: products[index]['price']!,
                              imagePath: products[index]['image']!,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
