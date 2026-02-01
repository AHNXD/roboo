import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/utils/assets_data.dart';
import '../../../../../core/utils/colors.dart';
import '../../../../../core/widgets/custom_back_button.dart';
import '../../../../../core/widgets/primary_button.dart';

class ProductDetailsScreen extends StatelessWidget {
  static const String routeName = "/product-details";
  final String title;
  final String price;
  final String imagePath;
  final String description;
  final bool isFav = true;
  ProductDetailsScreen({
    super.key,
    required this.title,
    required this.price,
    required this.imagePath,
    this.description =
        "طقم تعليمي مبتكر يجمع بين المتعة والتعلم، مخصص لتعريف الأطفال والمبتدئين على أساسيات الروبوتات والبرمجة. يضم الطقم مكونات ميكانيكية وإلكترونية...",
  });
  final List<double> grayscaleMatrix = <double>[
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Image.asset(imagePath, fit: BoxFit.cover),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  CustomBackButton(
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.60,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDot(Colors.grey.shade300),
                      const SizedBox(width: 5),
                      _buildDot(AppColors.primaryColors),
                      const SizedBox(width: 5),
                      _buildDot(Colors.grey.shade300),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                title,
                                style: GoogleFonts.cairo(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              _buildFavIcon(),
                            ],
                          ),

                          const SizedBox(height: 15),

                          Text(
                            description,
                            textAlign: TextAlign.right,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.6,
                            ),
                          ),

                          const SizedBox(height: 25),

                          Text(
                            ":المواصفات",
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildSpecRow("الطول: 325 سم"),
                          _buildSpecRow("العرض: 210 سم"),
                          _buildSpecRow("عدد القطع: 312 قطعة"),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9F9),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            text: "أضف إلى السلة",
                            imagePath: AssetsData.forwardButton,
                            mainColor: AppColors.primaryTwoColors,
                            backgroundColor: AppColors.primaryColors,
                            onTap: () {},
                          ),
                        ),
                        SizedBox(width: 24),
                        Text(
                          price,
                          style: GoogleFonts.cairo(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildSpecRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildFavIcon() {
    return isFav
        ? Image.asset(AssetsData.fav, width: 40, height: 40)
        : ColorFiltered(
            colorFilter: ColorFilter.matrix(grayscaleMatrix),
            child: Image.asset(AssetsData.fav, width: 40, height: 40),
          );
  }
}
