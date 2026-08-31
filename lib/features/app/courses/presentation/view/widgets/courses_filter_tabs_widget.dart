import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/widgets/filter_chip_icon.dart';

class CourseFilterTabs extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelect;
  final List<Map<String, dynamic>> filters;
  final ScrollPhysics? physics;
  final Clip clipBehavior;

  const CourseFilterTabs({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    required this.filters,
    this.physics,
    this.clipBehavior = Clip.hardEdge,
  });

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context).languageCode;
    return SizedBox(
      height: 60,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        key: ValueKey(currentLocale),
        physics: physics,
        clipBehavior: clipBehavior,
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (c, i) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final bool isSelected = index == selectedIndex;
          const Color themeColor = AppColors.primaryColors;
          final filter = filters[index];
          final icon = filter['icon'];
          final label = filter['label']?.toString() ?? '';
          final shouldTranslate = filter['translateLabel'] as bool? ?? true;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: GestureDetector(
              onTap: () => onSelect(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? themeColor : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryTwoColors
                        : AppColors.secColors,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? AppColors.primaryTwoColors
                          : themeColor.withValues(alpha: 0.7),
                      blurRadius: isSelected ? 0 : 4,
                      spreadRadius: 0,
                      offset: Offset(0, (isSelected ? 3 : 0)),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon is String && icon.isNotEmpty) ...[
                      FilterChipIcon(source: icon),
                      const SizedBox(width: 12),
                    ],
                    Text(
                      shouldTranslate ? label.tr(context) : label,
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
    );
  }
}
