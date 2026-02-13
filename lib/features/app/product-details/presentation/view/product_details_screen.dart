import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/widgets/custom_back_button.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/widgets/favorite_icon_widget.dart';
import 'package:roboo/features/app/product-details/presentation/view/widgets/bottom_action_bar.dart';
import 'package:roboo/features/app/product-details/presentation/view/widgets/dots_indicator_widget.dart';
import 'package:roboo/features/app/product-details/presentation/view/widgets/specifications_row_widget.dart';

class ProductDetailsScreen extends StatelessWidget {
  static const String routeName = "/product-details";

  final String title;
  final String price;
  final String imagePath;
  final String? description;
  final bool isFav;

  const ProductDetailsScreen({
    super.key,
    required this.title,
    required this.price,
    required this.imagePath,
    this.description,
    this.isFav = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ProductBottomBar(price: price, onAddToCart: () {}),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(imagePath, fit: BoxFit.fill),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 16.0,
                    ),
                    child: CustomBackButton(
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: Column(
                children: [
                  // Dots
                  const ProductDotsIndicator(),

                  const SizedBox(height: 20),

                  // Scrollable Details
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title & Fav
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
                              FavIcon(isFav: isFav),
                            ],
                          ),

                          const SizedBox(height: 15),

                          // Description
                          Text(
                            description ?? "default_description".tr(context),
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.6,
                            ),
                          ),

                          const SizedBox(height: 25),

                          // Specs Header
                          Text(
                            "specifications".tr(context),
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Specs List
                          ProductSpecRow(text: "spec_length".tr(context)),
                          ProductSpecRow(text: "spec_width".tr(context)),
                          ProductSpecRow(text: "spec_pieces".tr(context)),
                        ],
                      ),
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
}
