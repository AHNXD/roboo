import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/core/widgets/load_more_listener.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/features/app/course/presentation/view/course_details_screen_screen.dart';
import 'package:roboo/features/app/notifications/data/models/notification_model.dart';
import 'package:roboo/features/app/notifications/presentation/view-model/notifications_cubit/notifications_cubit.dart';

class NotificationsScreen extends StatelessWidget {
  static const String routeName = "/notifications";

  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          NotificationsCubit(getit.get(), getit.get())..getNotifications(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppbar(title: "notifications_title".tr(context)),
        body: SafeArea(
          child: BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              return switch (state) {
                NotificationsInitial() ||
                NotificationsLoading() => StatusDisplayWidget(
                  message: "wait".tr(context),
                  withAnimation: true,
                ),
                NotificationsError(:final errorMsg) => StatusDisplayWidget(
                  message: errorMsg.tr(context),
                ),
                NotificationsEmpty() => StatusDisplayWidget(
                  message: "no_notifications".tr(context),
                ),
                NotificationsLoaded() => _NotificationsList(state: state),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _NotificationsList extends StatelessWidget {
  final NotificationsLoaded state;

  const _NotificationsList({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NotificationsCubit>();

    return Column(
      children: [
        if (state.unreadCount > 0)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextButton.icon(
                onPressed: cubit.markAllRead,
                icon: const Icon(
                  Icons.done_all,
                  size: 18,
                  color: AppColors.primaryColors,
                ),
                label: Text(
                  "mark_all_read".tr(context),
                  style: GoogleFonts.cairo(
                    color: AppColors.primaryColors,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),

        Expanded(
          child: RefreshIndicator(
            onRefresh: cubit.getNotifications,
            child: LoadMoreListener(
              canLoadMore: state.hasMore && !state.isLoadingMore,
              onLoadMore: cubit.loadMore,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount:
                    state.notifications.length + (state.isLoadingMore ? 1 : 0),
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  if (index >= state.notifications.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColors,
                        ),
                      ),
                    );
                  }

                  final notification = state.notifications[index];
                  return _NotificationCard(
                    notification: notification,
                    onTap: () => _open(context, cubit, notification),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Opening a notification marks it read and, when it points at a course,
  /// takes the student there — the same routing a tap on the push performs.
  void _open(
    BuildContext context,
    NotificationsCubit cubit,
    NotificationModel notification,
  ) {
    cubit.markRead(notification);

    final courseId = notification.courseId;
    if (notification.isCourseNotification && courseId != null) {
      Navigator.pushNamed(
        context,
        CourseDetailsScreen.routeName,
        arguments: CourseDetailsArgs(courseId: courseId),
      );
    }
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          // Unread is carried by fill and a dot, not by colour alone.
          color: isUnread
              ? AppColors.primaryColors.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUnread
                ? AppColors.primaryColors.withValues(alpha: 0.35)
                : Colors.grey.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                notification.isCourseNotification
                    ? Icons.school_outlined
                    : Icons.campaign_outlined,
                color: AppColors.primaryColors,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title ?? '',
                    style: GoogleFonts.cairo(
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if ((notification.body ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      notification.body!,
                      style: GoogleFonts.cairo(
                        color: Colors.grey[700],
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    notification.displayDate,
                    style: GoogleFonts.cairo(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (isUnread)
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primaryColors,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
