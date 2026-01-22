import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';
import 'package:roboo/core/utils/roboo_shapes.dart';

class Category3DCard extends StatelessWidget {
  final String title;
  final String image;
  final Color color;
  final Color shadowColor;
  final double height;
  final Offset shadowOffset;
  final CardShapeType shapeType;

  final double slopeDepth;

  const Category3DCard({
    super.key,
    required this.title,
    required this.image,
    required this.color,
    required this.shadowColor,
    required this.height,
    required this.shadowOffset,
    required this.shapeType,
    this.slopeDepth = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: shadowOffset.dy,
            left: shadowOffset.dx > 0 ? shadowOffset.dx : 0,
            right: shadowOffset.dx < 0 ? -shadowOffset.dx : 0,
            bottom: 0,
            child: ClipPath(
              clipper: CardShapeClipper(
                shapeType: shapeType,
                slopeDepth: slopeDepth,
              ),
              child: Container(color: shadowColor),
            ),
          ),

          Positioned(
            top: 0,
            left: shadowOffset.dx < 0 ? -shadowOffset.dx : 0,
            right: shadowOffset.dx > 0 ? shadowOffset.dx : 0,
            bottom: shadowOffset.dy,
            child: ClipPath(
              clipper: CardShapeClipper(
                shapeType: shapeType,
                slopeDepth: slopeDepth,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 6),
                color: color,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(flex: 1),
                    Center(child: Image.asset(image, width: 50, height: 50)),
                    Spacer(),
                    Column(
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        HexagonWidget.flat(
                          width: 18,
                          color: Colors.white,
                          cornerRadius: 2,
                          child: Icon(Icons.hexagon, size: 12, color: color),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
