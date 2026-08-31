import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/models/pagination_model.dart';
import '../../../../../../core/utils/safe_emit.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repos/notifications_repo.dart';
import '../notifications_badge_cubit/notifications_badge_cubit.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState>
    with SafeEmit<NotificationsState> {
  final NotificationsRepo _notificationsRepo;

  /// The bell's badge. Kept in step from here rather than re-fetching, since
  /// every change to the count happens on this screen.
  final NotificationsBadgeCubit _badgeCubit;

  NotificationsCubit(this._notificationsRepo, this._badgeCubit)
    : super(const NotificationsInitial());

  List<NotificationModel> _notifications = const [];
  PaginationModel _pagination = PaginationModel.single;
  int _unreadCount = 0;
  bool _isLoadingMore = false;

  Future<void> getNotifications() async {
    safeEmit(const NotificationsLoading());

    final result = await _notificationsRepo.getNotifications();
    result.fold(
      (failure) => safeEmit(NotificationsError(errorMsg: failure.message)),
      (page) {
        _notifications = page.page.items;
        _pagination = page.page.pagination;
        _unreadCount = page.unreadCount;
        _badgeCubit.setCount(_unreadCount);

        safeEmit(
          _notifications.isEmpty
              ? const NotificationsEmpty()
              : _loaded(hasMore: page.page.hasMore),
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_pagination.hasMore) return;

    _isLoadingMore = true;
    safeEmit(_loaded(hasMore: true, isLoadingMore: true));

    final result = await _notificationsRepo.getNotifications(
      page: _pagination.nextPage,
    );

    _isLoadingMore = false;

    result.fold((_) => safeEmit(_loaded(hasMore: _pagination.hasMore)), (page) {
      _notifications = [..._notifications, ...page.page.items];
      _pagination = page.page.pagination;
      _unreadCount = page.unreadCount;
      _badgeCubit.setCount(_unreadCount);
      safeEmit(_loaded(hasMore: page.page.hasMore));
    });
  }

  /// Marks one as read. The row updates immediately and reverts if the request
  /// fails, so the badge never disagrees with the server for long.
  Future<void> markRead(NotificationModel notification) async {
    final id = notification.id;
    if (id == null || notification.isRead) return;

    _setRead(id, true);
    _unreadCount = (_unreadCount - 1).clamp(0, 1 << 30);
    _badgeCubit.setCount(_unreadCount);
    safeEmit(_loaded(hasMore: _pagination.hasMore));

    final result = await _notificationsRepo.markRead(notificationId: id);
    result.fold((_) {
      _setRead(id, false);
      _unreadCount += 1;
      _badgeCubit.setCount(_unreadCount);
      safeEmit(_loaded(hasMore: _pagination.hasMore));
    }, (_) {});
  }

  Future<void> markAllRead() async {
    if (_unreadCount == 0) return;

    final previous = _notifications;
    final previousUnread = _unreadCount;

    _notifications = _notifications
        .map((notification) => notification.copyWith(isRead: true))
        .toList();
    _unreadCount = 0;
    _badgeCubit.clear();
    safeEmit(_loaded(hasMore: _pagination.hasMore));

    final result = await _notificationsRepo.markAllRead();
    result.fold((_) {
      _notifications = previous;
      _unreadCount = previousUnread;
      _badgeCubit.setCount(previousUnread);
      safeEmit(_loaded(hasMore: _pagination.hasMore));
    }, (_) {});
  }

  void _setRead(int id, bool isRead) {
    _notifications = _notifications
        .map(
          (notification) => notification.id == id
              ? notification.copyWith(isRead: isRead)
              : notification,
        )
        .toList();
  }

  NotificationsLoaded _loaded({
    required bool hasMore,
    bool isLoadingMore = false,
  }) {
    return NotificationsLoaded(
      notifications: _notifications,
      unreadCount: _unreadCount,
      hasMore: hasMore,
      isLoadingMore: isLoadingMore,
    );
  }
}
