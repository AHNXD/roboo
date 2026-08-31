import 'package:dartz/dartz.dart';

import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/Api_services/urls.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../../../../../core/models/pagination_model.dart';
import '../models/notification_model.dart';
import 'notifications_repo.dart';

class NotificationsRepoImpl implements NotificationsRepo {
  final ApiServices _apiServices;

  NotificationsRepoImpl(this._apiServices);

  @override
  Future<Either<Failure, NotificationsPage>> getNotifications({
    int page = 1,
  }) async {
    try {
      final response = await _apiServices.get(endPoint: _endpoint(page));
      final responseData = response.data;

      if (response.statusCode == 200 &&
          responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        final data = responseData['data'];
        final items = data is Map<String, dynamic>
            ? data['notifications']
            : null;

        if (items is List) {
          final notifications = items
              .whereType<Map<String, dynamic>>()
              .map(NotificationModel.fromJson)
              .toList();

          return right(
            NotificationsPage(
              page: PagedResult(
                items: notifications,
                pagination: PaginationModel.fromJson(
                  data is Map<String, dynamic> &&
                          data['pagination'] is Map<String, dynamic>
                      ? data['pagination'] as Map<String, dynamic>
                      : null,
                ),
              ),
              unreadCount: _parseInt(
                data is Map<String, dynamic> ? data['unread_count'] : null,
              ),
            ),
          );
        }

        return left(ServerFailure(ErrorHandler.defaultMessage()));
      }

      return left(_serverFailure(responseData));
    } catch (error) {
      return left(ErrorHandler.handle(error));
    }
  }

  @override
  Future<Either<Failure, Unit>> markRead({required int notificationId}) {
    return _post(Urls.notificationRead(notificationId));
  }

  @override
  Future<Either<Failure, Unit>> markAllRead() {
    return _post(Urls.notificationsMarkAllRead);
  }

  Future<Either<Failure, Unit>> _post(String endPoint) async {
    try {
      final response = await _apiServices.post(endPoint: endPoint, data: {});
      final responseData = response.data;

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        return right(unit);
      }

      return left(_serverFailure(responseData));
    } catch (error) {
      return left(ErrorHandler.handle(error));
    }
  }

  /// The list endpoint spells its page-size parameter `perPage`, unlike every
  /// other endpoint — and the app does not set it anyway, since the backend
  /// fixes the size regardless.
  String _endpoint(int page) => pagedEndpoint(Urls.notifications, page);

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  ServerFailure _serverFailure(dynamic responseData) {
    return ServerFailure(
      responseData is Map<String, dynamic>
          ? responseData['message']?.toString() ?? ErrorHandler.defaultMessage()
          : ErrorHandler.defaultMessage(),
    );
  }
}
