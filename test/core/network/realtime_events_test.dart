import 'package:flutter_test/flutter_test.dart';
import 'package:sfa/core/network/app_config.dart';
import 'package:sfa/core/network/realtime_events.dart';
import 'package:sfa/features/notifications/data/notification_models.dart';

/// The gateway's payloads are hand-built in some events and re-emitted Mongo
/// documents in others, so every parser has to accept both spellings — these
/// lock that in.
void main() {
  group('RealtimeOrderUpdate', () {
    test('parses the guide\'s order:status_updated payload', () {
      final update = RealtimeOrderUpdate.fromJson(const {
        'orderId': '6aa1276bd3114029cc44dbb8',
        'orderNumber': 'ORD-4DBB8',
        'status': 'confirmed',
        'paymentStatus': 'PAID',
        'updatedAt': '2026-09-09T10:15:30.000Z',
      });

      expect(update.orderId, '6aa1276bd3114029cc44dbb8');
      expect(update.orderNumber, 'ORD-4DBB8');
      expect(update.status, 'confirmed');
      expect(update.paymentStatus, 'PAID');
      expect(update.updatedAt, isNotNull);
    });

    test('falls back to _id when the event carries a raw document', () {
      final update = RealtimeOrderUpdate.fromJson(const {
        '_id': 'abc123',
        'status': 'delivered',
      });

      expect(update.orderId, 'abc123');
      expect(update.orderNumber, isEmpty);
      expect(update.updatedAt, isNull);
    });
  });

  group('DriverLocation', () {
    test('parses a GPS ping', () {
      final location = DriverLocation.fromJson(const {
        'deliveryId': 'del_1',
        'lat': 24.7136,
        'lng': 46.6753,
      });

      expect(location, isNotNull);
      expect(location!.deliveryId, 'del_1');
      expect(location.lat, 24.7136);
      expect(location.lng, 46.6753);
    });

    test('accepts string coordinates', () {
      final location = DriverLocation.fromJson(const {
        'latitude': '24.5',
        'longitude': '46.5',
      });

      expect(location!.lat, 24.5);
      expect(location.lng, 46.5);
      expect(location.deliveryId, isNull);
    });

    test('drops a ping with no usable coordinates', () {
      expect(DriverLocation.fromJson(const {'lat': 24.5}), isNull);
      expect(DriverLocation.fromJson(const {'lat': 'north', 'lng': 46.5}), isNull);
    });
  });

  group('AppNotification', () {
    test('parses the socket notification:new payload', () {
      final notification = AppNotification.fromJson(const {
        '_id': '67cf1b29a149c00192e21b88',
        'title': 'تم تأكيد طلبك بنجاح',
        'body': 'جاري تجهيز طلبك',
        'category': 'orders',
        'referenceType': 'order',
        'referenceId': '6aa1276bd3114029cc44dbb8',
        'isRead': false,
        'createdAt': '2026-09-09T10:15:30.000Z',
      });

      expect(notification.id, '67cf1b29a149c00192e21b88');
      expect(notification.type, 'orders');
      expect(notification.referenceType, 'order');
      expect(notification.referenceId, '6aa1276bd3114029cc44dbb8');
      expect(notification.isRead, isFalse);
      expect(notification.copyWith(isRead: true).isRead, isTrue);
    });
  });

  test('socketUrl drops the REST prefix from the API base url', () {
    expect(AppConfig.socketUrl, isNot(endsWith('/api/v1')));
    expect(AppConfig.baseUrl, startsWith(AppConfig.socketUrl));
  });
}
