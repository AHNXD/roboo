import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/utils/safe_emit.dart';
import '../../../data/repos/notifications_repo.dart';

/// The unread count behind the bell icon, app-wide.
///
/// Separate from `NotificationsCubit`, which owns the list on the notifications
/// screen: the badge has to be right on every screen with a top bar, including
/// before that screen has ever been opened.
class NotificationsBadgeCubit extends Cubit<int> with SafeEmit<int> {
  final NotificationsRepo _notificationsRepo;

  NotificationsBadgeCubit(this._notificationsRepo) : super(0);

  bool _isLoading = false;

  Future<void> refresh() async {
    if (_isLoading) return;
    _isLoading = true;

    final result = await _notificationsRepo.getNotifications();
    _isLoading = false;

    // A failure leaves the badge as it was: a wrong count is worse than a
    // stale one, and there is nothing the student could do about an error here.
    result.fold((_) {}, (page) => safeEmit(page.unreadCount));
  }

  /// The notifications screen already knows the count from its own fetch, so it
  /// hands it over instead of making the badge fetch again.
  void setCount(int unreadCount) => safeEmit(unreadCount.clamp(0, 1 << 30));

  /// A push arrived while the app was open.
  void increment() => safeEmit(state + 1);

  void clear() => safeEmit(0);
}
