import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/widgets/custom_drawer.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/features/app/home/presentation/view/widgets/custom_app_bar.dart';
import 'package:roboo/features/app/news/presentation/view/widgets/news_card_widget.dart';

class NewsScreen extends StatefulWidget {
  static const String routeName = "/news";
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  // Set to [] to test Empty State
  final List<Map<String, String>> _newsList = [
    {
      "image": AssetsData.classRoom,
      "date": "25/10/2025",
      "title": "روبو يلهم صغار العقول في مدرسة القرية الصغيرة!",
      "body":
          "شارك فريق Roboo في يوم تعليمي مميز في مدرسة القرية الصغيرة، حيث قدّم للأطفال تجربة ممتعة ومليئة بالاكلصغيرة، حيث قدّم للأطفال تجربة ممتعة ومليئة بالاكتشاف في عالصغيرة، حيث قدّم للأطفال تجربة ممتعة ومليئة بالاكتشاف في عالم الروبوتات والبرمجة.لصغيرة، حيث قدّم للأطفال تجربة ممتعة ومليئة بالاكتشاف في عالم الروبوتات والبرمجة.لم الروبوتات والبرمجة.تشاف في عالم الروبوتات والبرمجة...",
    },
    {
      "image": AssetsData.trophy,
      "date": "20/10/2025",
      "title": "فوز فريق الروبوتيك بالمركز الأول!",
      "body":
          "حقق طلابنا إنجازاً رائعاً في المسابقة الوطنية للروبوتيك، حيث حصلوا على المركز الأول بفضل تصميمهم المبتكر...",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Bar
            const TopBarWidget(),

            const SizedBox(height: 10),

            // 2. News List or Empty State
            Expanded(
              child: _newsList.isEmpty
                  ? StatusDisplayWidget(
                      message: "no_news_available".tr(context),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: _newsList.length,
                      itemBuilder: (context, index) {
                        final news = _newsList[index];
                        return NewsCard(
                          imagePath: news['image']!,
                          date: news['date']!,
                          title: news['title']!,
                          body: news['body']!,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
