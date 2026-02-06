import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/widgets/custom_drawer.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/features/app/home/presentation/view/widgets/custom_app_bar.dart';
import 'package:roboo/features/app/product-details/presentation/view/product_details_screen.dart';
import 'package:roboo/features/app/store/presentation/view/widgets/product_card_widget.dart';
import 'package:roboo/features/app/store/presentation/view/widgets/store_filter_lits_widget.dart';

class StoreScreen extends StatefulWidget {
  static const String routeName = "/store";
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  int _selectedFilterIndex = 0;

  // Localization Keys for Filters
  final List<String> _filters = [
    "store_filter_all",
    "store_filter_robots",
    "store_filter_lego",
    "store_filter_source_code",
  ];

  // Mock Data
  // Toggle to [] to test empty state
  final List<Map<String, String>> _products = [
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
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Bar
            const TopBarWidget(),

            const SizedBox(height: 24),

            // 2. Filter List
            StoreFilterList(
              filters: _filters,
              selectedIndex: _selectedFilterIndex,
              onSelect: (index) {
                setState(() => _selectedFilterIndex = index);
                // Logic to filter _products list goes here
              },
            ),

            const SizedBox(height: 8),

            // 3. Grid or Empty State
            Expanded(
              child: _products.isEmpty
                  ? StatusDisplayWidget(
                      message: "no_products_found".tr(context),
                      // Optional: imagePath: AssetsData.flyingRoboo,
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 0.65,
                          ),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        return ProductCard(
                          title: product['title']!,
                          price: product['price']!,
                          imagePath: product['image']!,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailsScreen(
                                  title: product['title']!,
                                  price: product['price']!,
                                  imagePath: product['image']!,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
