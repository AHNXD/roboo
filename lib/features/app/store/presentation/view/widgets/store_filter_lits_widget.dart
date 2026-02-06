import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart';

class StoreFilterList extends StatelessWidget {
  final List<String> filters;
  final int selectedIndex;
  final Function(int) onSelect;

  const StoreFilterList({
    super.key,
    required this.filters,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
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
                padding: const EdgeInsets.symmetric(horizontal: 24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? themeColor : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: themeColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: themeColor.withValues(alpha: 0.5),
                      blurRadius: 4,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  filters[index].tr(context),
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
    );
  }
}
