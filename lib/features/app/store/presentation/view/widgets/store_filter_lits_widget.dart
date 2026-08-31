import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/filter_chip_icon.dart';

class StoreFilterList extends StatelessWidget {
  final List<String> filters;

  /// Optional icon per filter, aligned with [filters] by index. An entry may be
  /// empty — several categories have no picture uploaded — and that chip simply
  /// renders as text.
  final List<String> icons;
  final int selectedIndex;
  final Function(int) onSelect;
  final bool translateFilters;
  final EdgeInsetsGeometry padding;

  const StoreFilterList({
    super.key,
    required this.filters,
    this.icons = const [],
    required this.selectedIndex,
    required this.onSelect,
    this.translateFilters = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context).languageCode;
    return SizedBox(
      height: 60,
      child: ListView.separated(
        padding: padding,
        key: ValueKey(currentLocale),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (c, i) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final bool isSelected = index == selectedIndex;
          const Color themeColor = AppColors.primaryColors;

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
                    if (index < icons.length && icons[index].isNotEmpty) ...[
                      FilterChipIcon(source: icons[index], size: 22),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      translateFilters
                          ? filters[index].tr(context)
                          : filters[index],
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
