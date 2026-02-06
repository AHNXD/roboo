import 'package:flutter/material.dart';
import 'package:roboo/core/utils/colors.dart';

class ProductDotsIndicator extends StatelessWidget {
  const ProductDotsIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDot(Colors.grey.shade300),
        const SizedBox(width: 5),
        _buildDot(AppColors.primaryColors),
        const SizedBox(width: 5),
        _buildDot(Colors.grey.shade300),
      ],
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
