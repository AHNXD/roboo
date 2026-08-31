import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/custom_image_widget.dart';
import 'package:roboo/core/widgets/favorite_icon_widget.dart';
import '../../../../../../core/widgets/primary_button.dart';

class ProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String imagePath;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final bool isFavorite;
  final bool isFavoriteLoading;
  final VoidCallback? onToggleFavorite;

  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    required this.imagePath,
    required this.onTap,
    required this.onAddToCart,
    this.isFavorite = false,
    this.isFavoriteLoading = false,
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: onTap,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CustomImageWidget(
                          imageUrl: imagePath,
                          placeholderAsset: AssetsData.legoKit,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  if (onToggleFavorite != null)
                    PositionedDirectional(
                      top: 8,
                      end: 8,
                      child: FavIcon(
                        isFav: isFavorite,
                        isLoading: isFavoriteLoading,
                        onTap: onToggleFavorite,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Title
            GestureDetector(
              onTap: onTap,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
            ),

            // Price
            Text(
              price,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColors,
              ),
            ),

            const SizedBox(height: 10),

            // Add to Cart Button
            PrimaryButton(
              text: "add_to_cart".tr(context),
              enterButton: true,
              mainColor: AppColors.primaryTwoColors,
              backgroundColor: AppColors.primaryColors,
              onTap: onAddToCart,
            ),

            const SizedBox(height: 3),
          ],
        ),
      ),
    );
  }
}
