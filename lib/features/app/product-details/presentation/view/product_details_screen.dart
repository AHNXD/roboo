import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/functions.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/custom_back_button.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/widgets/custom_image_widget.dart';
import 'package:roboo/core/widgets/favorite_icon_widget.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/features/app/cart/presentation/view-model/cart_cubit/cart_cubit.dart';
import 'package:roboo/features/app/favorites/presentation/view-model/favorites_cubit/favorites_cubit.dart';
import 'package:roboo/features/app/product-details/data/models/product_details_model.dart';
import 'package:roboo/features/app/product-details/presentation/view-model/product_details_cubit/product_details_cubit.dart';
import 'package:roboo/features/app/product-details/presentation/view/widgets/bottom_action_bar.dart';
import 'package:roboo/features/app/product-details/presentation/view/widgets/dots_indicator_widget.dart';
import 'package:roboo/features/app/product-details/presentation/view/widgets/specifications_row_widget.dart';

class ProductDetailsArgs {
  final int productId;

  const ProductDetailsArgs({required this.productId});

  static int? productIdFrom(Object? args) {
    if (args is ProductDetailsArgs) return args.productId;
    if (args is int) return args;
    if (args is Map && args['productId'] is int) {
      return args['productId'] as int;
    }
    return null;
  }
}

class ProductDetailsScreen extends StatelessWidget {
  static const String routeName = "/product-details";

  final int? productId;
  final bool isFav;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
    this.isFav = false,
  });

  factory ProductDetailsScreen.fromRouteArgs(Object? args) {
    return ProductDetailsScreen(
      productId: ProductDetailsArgs.productIdFrom(args),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              ProductDetailsCubit(getit.get())..getProductDetails(productId),
        ),
        BlocProvider.value(value: getit<CartCubit>()),
        BlocProvider.value(value: getit<FavoritesCubit>()..loadFavorites()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<CartCubit, CartState>(
            listener: (context, state) {
              if (state is CartItemAdded) {
                messages(
                  context,
                  "cart_item_added".tr(context),
                  AppColors.green,
                );
              } else if (state is CartActionError) {
                messages(context, state.errorMsg.tr(context), AppColors.red);
              }
            },
          ),
          BlocListener<FavoritesCubit, FavoritesState>(
            listener: (context, state) {
              if (state is FavoriteToggleSuccess) {
                messages(
                  context,
                  state.isNowFavorite
                      ? "favorite_added".tr(context)
                      : "favorite_removed".tr(context),
                  AppColors.green,
                );
              } else if (state is FavoriteToggleError) {
                messages(context, state.errorMsg.tr(context), AppColors.red);
              }
            },
          ),
        ],
        child: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
          builder: (context, state) {
            return switch (state) {
              ProductDetailsInitial() ||
              ProductDetailsLoading() => _ProductDetailsStatusScaffold(
                child: StatusDisplayWidget(
                  message: "wait".tr(context),
                  withAnimation: true,
                ),
              ),
              ProductDetailsError(:final errorMsg) =>
                _ProductDetailsStatusScaffold(
                  child: StatusDisplayWidget(message: errorMsg.tr(context)),
                ),
              ProductDetailsLoaded(:final product) => _ProductDetailsContent(
                product: product,
                isFav: isFav,
              ),
            };
          },
        ),
      ),
    );
  }
}

class _ProductDetailsStatusScaffold extends StatelessWidget {
  final Widget child;

  const _ProductDetailsStatusScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: child),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 16.0,
              ),
              child: CustomBackButton(onTap: () => Navigator.pop(context)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductDetailsContent extends StatefulWidget {
  final ProductDetailsModel product;
  final bool isFav;

  const _ProductDetailsContent({required this.product, required this.isFav});

  @override
  State<_ProductDetailsContent> createState() => _ProductDetailsContentState();
}

class _ProductDetailsContentState extends State<_ProductDetailsContent> {
  int _selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final specifications = widget.product.specificationsFor(languageCode);
    final imageUrls = widget.product.imageUrls;
    final imageCount = imageUrls.isEmpty ? 1 : imageUrls.length;
    final favoritesState = context.watch<FavoritesCubit>().state;
    final isFavorite = favoritesState is FavoritesInitial
        ? widget.isFav
        : favoritesState.isFavorite(widget.product.id);
    final isFavoriteLoading =
        favoritesState is FavoriteToggleLoading &&
        favoritesState.productId == widget.product.id;

    return Scaffold(
      bottomNavigationBar: ProductBottomBar(
        price: widget.product.displayPrice,
        onAddToCart: () {
          context.read<CartCubit>().addProduct(productId: widget.product.id);
        },
      ),
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
                    child: PageView.builder(
                      itemCount: imageCount,
                      onPageChanged: (index) {
                        setState(() => _selectedImageIndex = index);
                      },
                      itemBuilder: (context, index) {
                        return CustomImageWidget(
                          imageUrl: imageUrls.isEmpty ? '' : imageUrls[index],
                          placeholderAsset: AssetsData.legoKit,
                          width: double.infinity,
                          fit: BoxFit.fill,
                        );
                      },
                    ),
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
                  ProductDotsIndicator(
                    count: imageCount,
                    selectedIndex: _selectedImageIndex,
                  ),

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
                              Expanded(
                                child: Text(
                                  widget.product.nameFor(languageCode),
                                  style: GoogleFonts.cairo(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              FavIcon(
                                isFav: isFavorite,
                                isLoading: isFavoriteLoading,
                                onTap: () {
                                  context.read<FavoritesCubit>().toggleFavorite(
                                    widget.product.id,
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          // Description
                          Text(
                            widget.product.descriptionFor(languageCode).isEmpty
                                ? "default_description".tr(context)
                                : widget.product.descriptionFor(languageCode),
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
                          if (specifications.isEmpty)
                            ProductSpecRow(
                              text: "no_specifications_found".tr(context),
                            )
                          else
                            ...specifications.map(
                              (specification) => ProductSpecRow(
                                text: specification.displayText,
                              ),
                            ),
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
