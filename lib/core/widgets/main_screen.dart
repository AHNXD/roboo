import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/widgets/ai_button.dart';
import 'package:roboo/features/app/courses/presentation/view/courses_screen.dart';
import 'package:roboo/features/app/home/presentation/view/home_screen.dart';
import 'package:roboo/features/app/news/presentation/view/news_screen.dart';
import 'package:roboo/features/app/roboo-ai/presentation/view/roboo_ai_screen.dart';

import '../../features/app/store/presentation/view/store_screen.dart';
import '../utils/app_localizations.dart';
import '../utils/colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  static const String routeName = "/main";

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CoursesScreen(),
    const NewsScreen(),
    const StoreScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const List<double> grayscaleMatrix = <double>[
      0.2126,
      0.7152,
      0.0722,
      0,
      0,
      0.2126,
      0.7152,
      0.0722,
      0,
      0,
      0.2126,
      0.7152,
      0.0722,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      floatingActionButton: DiamondFab(
        onPressed: () {
          Navigator.pushNamed(context, RobooAiScreen.routeName);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: ColorFiltered(
              colorFilter: const ColorFilter.matrix(grayscaleMatrix),
              child: Image.asset(AssetsData.home, height: 24),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.all(6),

              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColors.withValues(alpha: 0.5),
                border: Border.all(color: AppColors.secColors, width: 1.5),
              ),
              child: Image.asset(AssetsData.home, height: 24),
            ),
            label: 'home'.tr(context),
          ),
          BottomNavigationBarItem(
            icon: ColorFiltered(
              colorFilter: const ColorFilter.matrix(grayscaleMatrix),
              child: Image.asset(AssetsData.courses, height: 24),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.all(6),

              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColors.withValues(alpha: 0.5),
                border: Border.all(color: AppColors.secColors, width: 1.5),
              ),

              child: Image.asset(AssetsData.courses, height: 24),
            ),
            label: 'courses'.tr(context),
          ),
          BottomNavigationBarItem(
            icon: ColorFiltered(
              colorFilter: const ColorFilter.matrix(grayscaleMatrix),
              child: Image.asset(AssetsData.latestNews, height: 24),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.all(6),

              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColors.withValues(alpha: 0.5),
                border: Border.all(color: AppColors.secColors, width: 1.5),
              ),

              child: Image.asset(AssetsData.latestNews, height: 24),
            ),
            label: 'latest_news'.tr(context),
          ),
          BottomNavigationBarItem(
            icon: ColorFiltered(
              colorFilter: const ColorFilter.matrix(grayscaleMatrix),
              child: Image.asset(AssetsData.store, height: 24),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.all(6),

              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColors.withValues(alpha: 0.5),
                border: Border.all(color: AppColors.secColors, width: 1.5),
              ),
              child: Image.asset(AssetsData.store, height: 24),
            ),
            label: 'store'.tr(context),
          ),
        ],
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryColors,
        unselectedItemColor: AppColors.baseShimmerColor,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        elevation: 10,
      ),
    );
  }
}
