import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';

class HexagonProfileAvatar extends StatelessWidget {
  final String imagePath;
  final double size;
  final Color borderColor;

  const HexagonProfileAvatar({
    super.key,
    required this.imagePath,
    this.size = 120,
    this.borderColor = Colors.teal,
  });

  @override
  Widget build(BuildContext context) {
    return HexagonWidget.flat(
      width: size,
      color: borderColor,
      elevation: 6,
      cornerRadius: 10,
      child: HexagonWidget.flat(
        width: size - 6,
        color: Colors.white,
        padding: 2.0,
        cornerRadius: 10,
        child: ClipRRect(
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.person, color: borderColor),
          ),
        ),
      ),
    );
  }
}
