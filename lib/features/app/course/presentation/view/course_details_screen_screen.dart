import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/custom_back_button.dart';
import 'package:roboo/core/widgets/primary_button.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/features/app/course/presentation/view/widgets/activation_dialog_widget.dart';
import 'package:roboo/features/app/course/presentation/view/widgets/attachments_tab_widget.dart';
import 'package:roboo/features/app/course/presentation/view/widgets/course_info_tab_widget.dart';
import 'package:roboo/features/app/course/presentation/view/widgets/video_tab_widget.dart';
import 'video_player_screen.dart';

class CourseDetailsScreen extends StatefulWidget {
  static const String routeName = "/course-details";

  final bool isOnline;
  final String title;
  final String price;
  final bool isFav;

  const CourseDetailsScreen({
    super.key,
    required this.isOnline,
    required this.title,
    this.price = "100\$",
    this.isFav = false,
  });

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isActivated = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildBottomActionBar(context),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeaderBackground(context),
          Expanded(child: _buildBottomSheet(context)),
        ],
      ),
    );
  }

  Widget _buildHeaderBackground(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.3,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: AppColors.red,
                child: Center(
                  child: Icon(
                    Icons.coffee,
                    size: 100,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ),
            _buildSafeAreaBackButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSafeAreaBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomBackButton(onTap: () => Navigator.pop(context), isWhite: false),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Image.asset(AssetsData.programming, height: 24, width: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    return Column(
      children: [
        if (_isActivated) _buildTabBar(context),

        Expanded(
          child: _isActivated
              ? TabBarView(
                  controller: _tabController,
                  children: [
                    CourseInfoTab(
                      isOnline: widget.isOnline,
                      title: widget.title,
                      isFav: widget.isFav,
                    ),
                    const CourseVideosTab(),
                    const CourseAttachmentsTab(),
                  ],
                )
              : CourseInfoTab(
                  isOnline: widget.isOnline,
                  title: widget.title,
                  isFav: widget.isFav,
                ),
        ),
      ],
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
        isScrollable: true,
        tabAlignment: TabAlignment.center,
        labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        tabs: [
          Tab(text: "course_info_tab".tr(context)),
          Tab(text: "videos_tab".tr(context)),
          Tab(text: "attachments_tab".tr(context)),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 16),
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            offset: Offset(0, -1),
            blurRadius: 10,
          ),
        ],
        color: Colors.white,
      ),
      child: SafeArea(
        child: _isActivated
            ? PrimaryButton(
                text: "go_to_video".tr(context),
                backgroundColor: AppColors.primaryColors,
                mainColor: AppColors.primaryTwoColors,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => const VideoPlayerScreen(),
                    ),
                  );
                },
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: widget.isOnline
                          ? "book_now".tr(context)
                          : "book_via_whatsapp".tr(context),
                      enterButton: true,
                      backgroundColor: widget.isOnline
                          ? AppColors.primaryColors
                          : AppColors.green,
                      mainColor: widget.isOnline
                          ? AppColors.primaryTwoColors
                          : AppColors.shadowGreen,
                      onTap: () {
                        if (widget.isOnline) {
                          ActivationDialogs.showCodeInputDialog(context, () {
                            setState(() => _isActivated = true);
                          });
                        } else {}
                      },
                    ),
                  ),
                  const SizedBox(width: 24),
                  Text(
                    widget.price,
                    style: GoogleFonts.cairo(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
