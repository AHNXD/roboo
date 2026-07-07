import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/custom_image_widget.dart';

import '../../../data/models/order_model.dart';

class OrderItemCard extends StatelessWidget {
  final OrderItemModel item;
  final String languageCode;

  const OrderItemCard({
    super.key,
    required this.item,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final productName = product?.nameFor(languageCode);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CustomImageWidget(
              imageUrl: product?.thumbnailUrl ?? '',
              placeholderAsset: AssetsData.legoKit,
              width: 82,
              height: 82,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName?.isNotEmpty == true
                      ? productName!
                      : "order_product_unavailable".tr(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${"quantity".tr(context)}: ${item.quantity}",
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${"unit_price".tr(context)}: ${item.displayUnitPrice}",
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            item.displayLineTotal,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColors,
            ),
          ),
        ],
      ),
    );
  }
}
