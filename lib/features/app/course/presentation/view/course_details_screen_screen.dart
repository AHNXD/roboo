import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/custom_back_button.dart';
import 'package:roboo/core/widgets/favorite_icon_widget.dart';
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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Header (Red background + Icon)
          _buildHeaderBackground(context),

          // 2. Custom Back Button
          _buildSafeAreaBackButton(context),

          // 3. Bottom Sheet (White container with tabs)
          _buildBottomSheet(context),
        ],
      ),
    );
  }

  // --- Header Section ---
  Widget _buildHeaderBackground(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: MediaQuery.of(context).size.height * 0.40,
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
    );
  }

  Widget _buildSafeAreaBackButton(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomBackButton(
              onTap: () => Navigator.pop(context),
              isWhite: false,
            ),
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
      ),
    );
  }

  // --- Bottom Sheet Section ---
  Widget _buildBottomSheet(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.65,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Title & Favorite
            _buildTitleRow(context),

            const SizedBox(height: 10),

            // Tabs (Visible only when activated)
            if (_isActivated) _buildTabBar(context),

            // Tab Views
            Expanded(
              child: _isActivated
                  ? TabBarView(
                      controller: _tabController,
                      children: [
                        CourseInfoTab(isOnline: widget.isOnline),
                        const CourseVideosTab(),
                        const CourseAttachmentsTab(),
                      ],
                    )
                  : CourseInfoTab(isOnline: widget.isOnline),
            ),

            // Footer Actions
            _buildBottomActionBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              widget.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          FavIcon(isFav: widget.isFav),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF9F9F9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: _isActivated
          ? PrimaryButton(
              text: "go_to_video".tr(context),
              backgroundColor: AppColors.primaryColors,
              mainColor: AppColors.primaryTwoColors,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const VideoPlayerScreen()),
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
                    imagePath: AssetsData.forwardButton,
                    backgroundColor: widget.isOnline
                        ? AppColors.primaryColors
                        : const Color(0xFF25D366),
                    mainColor: widget.isOnline
                        ? AppColors.primaryTwoColors
                        : const Color(0xFF128C7E),
                    onTap: () {
                      if (widget.isOnline) {
                        ActivationDialogs.showCodeInputDialog(context, () {
                          setState(() => _isActivated = true);
                        });
                      } else {
                        // WhatsApp Logic
                      }
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
    );
  }
}
