import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roboo/core/utils/functions.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:roboo/core/widgets/custom_drawer.dart';
import 'package:roboo/core/widgets/load_more_listener.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/features/app/cart/presentation/view-model/cart_cubit/cart_cubit.dart';
import 'package:roboo/features/app/favorites/presentation/view-model/favorites_cubit/favorites_cubit.dart';
import 'package:roboo/features/app/home/presentation/view/widgets/custom_app_bar.dart';
import 'package:roboo/features/app/product-details/presentation/view/product_details_screen.dart';
import 'package:roboo/features/app/store/data/models/store_category_model.dart';
import 'package:roboo/features/app/store/data/models/store_product_model.dart';
import 'package:roboo/features/app/store/presentation/view-model/store_cubit/store_cubit.dart';
import 'package:roboo/features/app/store/presentation/view/widgets/product_card_widget.dart';
import 'package:roboo/features/app/store/presentation/view/widgets/store_filter_lits_widget.dart';
import 'package:roboo/features/app/store/presentation/view/widgets/store_search_field_widget.dart';

class StoreScreen extends StatelessWidget {
  static const String routeName = "/store";
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => StoreCubit(getit.get())..getStoreData()),
        BlocProvider.value(value: getit<CartCubit>()),
        BlocProvider.value(value: getit<FavoritesCubit>()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<CartCubit, CartState>(
            // Both this screen and the one pushed over it listen to the same
            // app-wide cubit, so without this the message appears once per
            // mounted listener. Only the visible route reports.
            listenWhen: (_, _) => ModalRoute.of(context)?.isCurrent ?? true,
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
            // Both this screen and the one pushed over it listen to the same
            // app-wide cubit, so without this the message appears once per
            // mounted listener. Only the visible route reports.
            listenWhen: (_, _) => ModalRoute.of(context)?.isCurrent ?? true,
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
                        :final searchQuery,
                      ) =>
                        _StoreContent(
                          categories: _filterLabels(context, categories),
                          categoryIcons: _filterIcons(categories),
                          selectedIndex: selectedIndex,
                          products: const [],
                          searchQuery: searchQuery,
                          isLoading: true,
                        ),
                      StoreProductsError(
                        :final categories,
                        :final selectedIndex,
                        :final searchQuery,
                        :final errorMsg,
                      ) =>
                        _StoreContent(
                          categories: _filterLabels(context, categories),
                          categoryIcons: _filterIcons(categories),
                          selectedIndex: selectedIndex,
                          products: const [],
                          searchQuery: searchQuery,
                          errorMessage: errorMsg.tr(context),
                        ),
                      StoreEmpty(
                        :final categories,
                        :final selectedIndex,
                        :final searchQuery,
                      ) =>
                        _StoreContent(
                          categories: _filterLabels(context, categories),
                          categoryIcons: _filterIcons(categories),
                          selectedIndex: selectedIndex,
                          products: const [],
                          searchQuery: searchQuery,
                        ),
                      StoreLoaded(
                        :final categories,
                        :final products,
                        :final selectedIndex,
                        :final searchQuery,
                        :final hasMore,
                        :final isLoadingMore,
                      ) =>
                        _StoreContent(
                          categories: _filterLabels(context, categories),
                          categoryIcons: _filterIcons(categories),
                          selectedIndex: selectedIndex,
                          products: products,
                          searchQuery: searchQuery,
                          hasMore: hasMore,
                          isLoadingMore: isLoadingMore,
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

  /// Index-aligned with [_filterLabels]; the leading "all" chip has no icon.
  List<String> _filterIcons(List<StoreCategoryModel> categories) {
    return ['', ...categories.map((category) => category.imageUrl)];
  }
}

class _StoreContent extends StatelessWidget {
  final List<String> categories;
  final List<String> categoryIcons;
  final int selectedIndex;
  final List<StoreProductModel> products;
  final String searchQuery;
  final bool isLoading;
  final bool hasMore;
  final bool isLoadingMore;
  final String? errorMessage;

  const _StoreContent({
    required this.categories,
    this.categoryIcons = const [],
    required this.selectedIndex,
    required this.products,
    this.searchQuery = '',
    this.isLoading = false,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final storeCubit = context.read<StoreCubit>();

    return Expanded(
      child: Column(
        children: [
          StoreSearchField(
            onChanged: storeCubit.search,
            onCleared: storeCubit.clearSearch,
          ),

          const SizedBox(height: 8),

          // Favourites moved to the drawer, so the categories get the whole row.
          SizedBox(
            height: 60,
            child: StoreFilterList(
              filters: categories,
              icons: categoryIcons,
              selectedIndex: selectedIndex,
              translateFilters: false,
              padding: const EdgeInsets.symmetric(vertical: 6),
              onSelect: context.read<StoreCubit>().selectCategory,
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
      return StatusDisplayWidget(
        message: searchQuery.isEmpty
            ? "no_products_found".tr(context)
            : "${"no_search_results".tr(context)} \"$searchQuery\"",
      );
    }

    return LoadMoreListener(
      canLoadMore: hasMore && !isLoadingMore,
      onLoadMore: context.read<StoreCubit>().loadMoreProducts,
      child: _ProductsGrid(products: products, isLoadingMore: isLoadingMore),
    );
  }
}

class _ProductsGrid extends StatelessWidget {
  final List<StoreProductModel> products;
  final bool isLoadingMore;

  const _ProductsGrid({required this.products, this.isLoadingMore = false});

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final favoritesState = context.watch<FavoritesCubit>().state;

    // A sliver grid rather than GridView.builder, so the "loading more" spinner
    // can sit under the grid inside the same scrollable.
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.6,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildCard(
                context,
                products[index],
                languageCode,
                favoritesState,
              ),
              childCount: products.length,
            ),
          ),
        ),
        if (isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryColors,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context,
    StoreProductModel product,
    String languageCode,
    FavoritesState favoritesState,
  ) {
    return ProductCard(
      title: product.nameFor(languageCode),
      price: product.displayPrice,
      imagePath: product.thumbnailUrl,
      isFavorite: favoritesState.isFavorite(
        product.id,
        fallback: product.isFavorite,
      ),
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
            builder: (context) => ProductDetailsScreen(productId: product.id),
          ),
        );
      },
      onAddToCart: () {
        context.read<CartCubit>().addProduct(productId: product.id);
      },
    );
  }
}
