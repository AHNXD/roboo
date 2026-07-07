import 'package:flutter/material.dart';
import 'package:roboo/core/utils/colors.dart';

class ProductDotsIndicator extends StatelessWidget {
  final int count;
  final int selectedIndex;

  const ProductDotsIndicator({
    super.key,
    this.count = 3,
    this.selectedIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final safeCount = count < 1 ? 1 : count;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(safeCount, (index) {
        return Padding(
          padding: EdgeInsetsDirectional.only(
            end: index == safeCount - 1 ? 0 : 5,
          ),
          child: _buildDot(selected: index == selectedIndex),
        );
      }),
    );
  }

  Widget _buildDot({bool selected = false}) {
    return Container(
      width: selected ? 16 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryColors : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
