import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/features/app/home/presentation/view/widgets/custom_app_bar.dart';

import '../../../../../core/widgets/custom_drawer.dart';
import 'widgets/news_card_widget.dart';

class NewsScreen extends StatefulWidget {
  static const String routeName = "/news";
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            TopBarWidget(),
            SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  NewsCard(
                    imagePath: AssetsData.classRoom,
                    date: "25/10/2025",
                    title: "روبو يلهم صغار العقول في مدرسة القرية الصغيرة!",
                    body:
                        "شارك فريق Roboo في يوم تعليمي مميز في مدرسة القرية الصغيرة، حيث قدّم للأطفال تجربة ممتعة ومليئة بالاكتشاف في عالم الروبوتات والبرمجة. من خلال أنشط في يوم تعليمي مميز في مدرسة القرية الصغيرة، حيث قدّم للأطفال تجربة ممتعة ومليئة بالاكتشاف في عالم الروبوتات والبرمجة. من خلال أ في يوم تعليمي مميز في مدرسة القرية الصغيرة، حيث قدّم للأطفال تجربة ممتعة ومليئة بالاكتشاف في عالم الروبوتات والبرمجة. من خلال أة تفاعلية وألعاب تعليمية...",
                  ),
                  NewsCard(
                    imagePath: AssetsData.trophy,
                    date: "25/10/2025",
                    title: "روبو يلهم صغار العقول في مدرسة القرية الصغيرة!",
                    body:
                        "شارك فريق Roboo في يوم تعليمي مميز في مدرسة القرية الصغيرة، حيث قدّم للأطفال تجربة ممتعة ومليئة بالاكتشاف في عالم الروبوتات والبرمجة. من خلال أنشط في يوم تعليمي مميز في مدرسة القرية الصغيرة، حيث قدّم للأطفال تجربة ممتعة ومليئة بالاكتشاف في عالم الروبوتات والبرمجة. من خلال أ في يوم تعليمي مميز في مدرسة القرية الصغيرة، حيث قدّم للأطفال تجربة ممتعة ومليئة بالاكتشاف في عالم الروبوتات والبرمجة. من خلال أة تفاعلية وألعاب تعليمية...",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
