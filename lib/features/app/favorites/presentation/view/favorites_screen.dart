import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/utils/functions.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/features/app/favorites/presentation/view-model/favorites_cubit/favorites_cubit.dart';
import 'package:roboo/features/app/favorites/presentation/view/widgets/favorite_product_card_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/features/app/courses/presentation/view-model/course_favorites_cubit/course_favorites_cubit.dart';
import 'package:roboo/features/app/favorites/presentation/view/widgets/favorite_courses_tab.dart';
import 'package:roboo/features/app/product-details/presentation/view/product_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  static const String routeName = "/favorites";

  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Courses live in their own app-wide cubit; the products one is refreshed
    // by the provider below.
    getit<CourseFavoritesCubit>().loadFavoriteCourses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getit<FavoritesCubit>()..refreshFavorites(),
      child: BlocConsumer<FavoritesCubit, FavoritesState>(
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
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: CustomAppbar(title: "favorites_title".tr(context)),
            body: Column(
              children: [
                _buildTabBar(context),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _FavoritesBody(state: state),
                      const FavoriteCoursesTab(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primaryColors,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppColors.primaryColors,
        labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        tabs: [
          Tab(text: "store".tr(context)),
          Tab(text: "courses".tr(context)),
        ],
      ),
    );
  }
}

class _FavoritesBody extends StatelessWidget {
  final FavoritesState state;

  const _FavoritesBody({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is FavoritesLoading && state.products.isEmpty) {
      return StatusDisplayWidget(
        message: "wait".tr(context),
        withAnimation: true,
      );
    }

    if (state is FavoritesError && state.products.isEmpty) {
      final errorState = state as FavoritesError;
      return StatusDisplayWidget(message: errorState.errorMsg.tr(context));
    }

    if (state.products.isEmpty) {
      return StatusDisplayWidget(message: "no_favorites_found".tr(context));
    }

    final languageCode = Localizations.localeOf(context).languageCode;

    return RefreshIndicator(
      onRefresh: context.read<FavoritesCubit>().refreshFavorites,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        itemCount: state.products.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final product = state.products[index];
          final isToggleLoading =
              state is FavoriteToggleLoading &&
              (state as FavoriteToggleLoading).productId == product.id;

          return FavoriteProductCard(
            product: product,
            languageCode: languageCode,
            isToggleLoading: isToggleLoading,
            onTap: () {
              final productId = product.id;
              if (productId == null) return;

              Navigator.pushNamed(
                context,
                ProductDetailsScreen.routeName,
                arguments: ProductDetailsArgs(productId: productId),
              );
            },
            onToggleFavorite: () {
              context.read<FavoritesCubit>().toggleFavorite(product.id);
            },
          );
        },
      ),
    );
  }
}
