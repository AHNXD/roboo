part of 'notifications_cubit.dart';

sealed class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

final class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

final class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

final class NotificationsEmpty extends NotificationsState {
  const NotificationsEmpty();
}

final class NotificationsLoaded extends NotificationsState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final bool hasMore;
  final bool isLoadingMore;

  const NotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [
    notifications,
    unreadCount,
    hasMore,
    isLoadingMore,
  ];
}

final class NotificationsError extends NotificationsState {
  final String errorMsg;

  const NotificationsError({required this.errorMsg});

  @override
  List<Object?> get props => [errorMsg];
}
