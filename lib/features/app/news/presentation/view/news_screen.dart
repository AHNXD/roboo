import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:roboo/core/widgets/custom_drawer.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/features/app/home/presentation/view/widgets/custom_app_bar.dart';
import 'package:roboo/features/app/news/presentation/view-model/news_cubit/news_cubit.dart';
import 'package:roboo/features/app/news/presentation/view/widgets/news_card_widget.dart';

class NewsScreen extends StatelessWidget {
  static const String routeName = "/news";
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NewsCubit(getit.get())..getGalleries(),
      child: Scaffold(
        drawer: const CustomDrawer(),
        body: SafeArea(
          child: Column(
            children: [
              // 1. Top Bar
              const TopBarWidget(),

              const SizedBox(height: 10),

              // 2. News List or Empty State
              Expanded(
                child: BlocBuilder<NewsCubit, NewsState>(
                  builder: (context, state) {
                    return switch (state) {
                      NewsInitial() || NewsLoading() => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      NewsError(:final errorMsg) => StatusDisplayWidget(
                        message: errorMsg.tr(context),
                      ),
                      NewsEmpty() => StatusDisplayWidget(
                        message: "no_news_available".tr(context),
                      ),
                      NewsLoaded(:final galleries) => RefreshIndicator(
                        onRefresh: context.read<NewsCubit>().getGalleries,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: galleries.length,
                          itemBuilder: (context, index) {
                            final gallery = galleries[index];
                            final languageCode = Localizations.localeOf(
                              context,
                            ).languageCode;

                            return NewsCard(
                              imagePaths: gallery.imageUrls,
                              date: gallery.displayDate,
                              title: gallery.titleFor(languageCode),
                              body: gallery.descriptionFor(languageCode),
                            );
                          },
                        ),
                      ),
                    };
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
