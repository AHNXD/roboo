import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failuer.dart';
import '../../../../../core/models/pagination_model.dart';
import '../models/notification_model.dart';

/// The unread count comes back with the list, so it is returned alongside the
/// page rather than fetched separately.
class NotificationsPage {
  final PagedResult<NotificationModel> page;
  final int unreadCount;

  const NotificationsPage({required this.page, required this.unreadCount});
}

abstract class NotificationsRepo {
  Future<Either<Failure, NotificationsPage>> getNotifications({int page = 1});

  Future<Either<Failure, Unit>> markRead({required int notificationId});

  Future<Either<Failure, Unit>> markAllRead();
}
