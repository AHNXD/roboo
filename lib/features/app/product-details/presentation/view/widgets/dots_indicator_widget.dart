import 'package:flutter/material.dart';
import 'package:roboo/core/utils/colors.dart';

class ProductDotsIndicator extends StatelessWidget {
  const ProductDotsIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDot(selected: true),
        const SizedBox(width: 5),
        _buildDot(),
        const SizedBox(width: 5),
        _buildDot(),
      ],
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
