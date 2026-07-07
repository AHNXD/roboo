import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/functions.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:roboo/core/widgets/custom_drawer.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/features/app/cart/presentation/view-model/cart_cubit/cart_cubit.dart';
import 'package:roboo/features/app/favorites/presentation/view/favorites_screen.dart';
import 'package:roboo/features/app/favorites/presentation/view-model/favorites_cubit/favorites_cubit.dart';
import 'package:roboo/features/app/home/presentation/view/widgets/custom_app_bar.dart';
import 'package:roboo/features/app/product-details/presentation/view/product_details_screen.dart';
import 'package:roboo/features/app/store/data/models/store_category_model.dart';
import 'package:roboo/features/app/store/data/models/store_product_model.dart';
import 'package:roboo/features/app/store/presentation/view-model/store_cubit/store_cubit.dart';
import 'package:roboo/features/app/store/presentation/view/widgets/product_card_widget.dart';
import 'package:roboo/features/app/store/presentation/view/widgets/store_filter_lits_widget.dart';

class StoreScreen extends StatelessWidget {
  static const String routeName = "/store";
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => StoreCubit(getit.get())..getStoreData()),
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
        child: Scaffold(
          drawer: const CustomDrawer(),
          body: SafeArea(
            child: Column(
              children: [
                // 1. Top Bar
                const TopBarWidget(),

                const SizedBox(height: 24),

                BlocBuilder<StoreCubit, StoreState>(
                  builder: (context, state) {
                    return switch (state) {
                      StoreInitial() || StoreLoading() => Expanded(
                        child: StatusDisplayWidget(
                          message: "wait".tr(context),
                          withAnimation: true,
                        ),
                      ),
                      StoreError(:final errorMsg) => Expanded(
                        child: StatusDisplayWidget(
                          message: errorMsg.tr(context),
                        ),
                      ),
                      StoreProductsLoading(
                        :final categories,
                        :final selectedIndex,
                      ) =>
                        _StoreContent(
                          categories: _filterLabels(context, categories),
                          selectedIndex: selectedIndex,
                          products: const [],
                          isLoading: true,
                        ),
                      StoreProductsError(
                        :final categories,
                        :final selectedIndex,
                        :final errorMsg,
                      ) =>
                        _StoreContent(
                          categories: _filterLabels(context, categories),
                          selectedIndex: selectedIndex,
                          products: const [],
                          errorMessage: errorMsg.tr(context),
                        ),
                      StoreEmpty(:final categories, :final selectedIndex) =>
                        _StoreContent(
                          categories: _filterLabels(context, categories),
                          selectedIndex: selectedIndex,
                          products: const [],
                        ),
                      StoreLoaded(
                        :final categories,
                        :final products,
                        :final selectedIndex,
                      ) =>
                        _StoreContent(
                          categories: _filterLabels(context, categories),
                          selectedIndex: selectedIndex,
                          products: products,
                        ),
                    };
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> _filterLabels(
    BuildContext context,
    List<StoreCategoryModel> categories,
  ) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return [
      "store_filter_all".tr(context),
      ...categories.map((category) => category.nameFor(languageCode)),
    ];
  }
}

class _StoreContent extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final List<StoreProductModel> products;
  final bool isLoading;
  final String? errorMessage;

  const _StoreContent({
    required this.categories,
    required this.selectedIndex,
    required this.products,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              height: 60,
              child: Row(
                children: [
                  _FavoritesFilterButton(
                    onTap: () {
                      Navigator.pushNamed(context, FavoritesScreen.routeName);
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StoreFilterList(
                      filters: categories,
                      selectedIndex: selectedIndex,
                      translateFilters: false,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      onSelect: context.read<StoreCubit>().selectCategory,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 3. Grid or Empty State
          Expanded(child: _buildProductsContent(context)),
        ],
      ),
    );
  }

  Widget _buildProductsContent(BuildContext context) {
    if (isLoading) {
      return StatusDisplayWidget(
        message: "wait".tr(context),
        withAnimation: true,
      );
    }

    final message = errorMessage;
    if (message != null) {
      return StatusDisplayWidget(message: message);
    }

    if (products.isEmpty) {
      return StatusDisplayWidget(message: "no_products_found".tr(context));
    }

    return _ProductsGrid(products: products);
  }
}

class _FavoritesFilterButton extends StatelessWidget {
  final VoidCallback onTap;

  const _FavoritesFilterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    const themeColor = AppColors.primaryColors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.secColors, width: 1),
            boxShadow: [
              BoxShadow(
                color: themeColor.withValues(alpha: 0.7),
                blurRadius: 4,
                spreadRadius: 0,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite_rounded, color: themeColor, size: 18),
              const SizedBox(width: 8),
              Text(
                "favorites_title".tr(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  color: themeColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductsGrid extends StatelessWidget {
  final List<StoreProductModel> products;

  const _ProductsGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final favoritesState = context.watch<FavoritesCubit>().state;

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.6,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          title: product.nameFor(languageCode),
          price: product.displayPrice,
          imagePath: product.thumbnailUrl,
          isFavorite: favoritesState.isFavorite(product.id),
          isFavoriteLoading:
              favoritesState is FavoriteToggleLoading &&
              favoritesState.productId == product.id,
          onToggleFavorite: () {
            context.read<FavoritesCubit>().toggleFavorite(product.id);
          },
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProductDetailsScreen(productId: product.id),
              ),
            );
          },
          onAddToCart: () {
            context.read<CartCubit>().addProduct(productId: product.id);
          },
        );
      },
    );
  }
}
