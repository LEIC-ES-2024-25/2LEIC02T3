import 'package:flutter_test/flutter_test.dart';
import '../lib/services/notification_service.dart';

void main() {
  group('Notification Tests', () {
    test('NotificationService should be a singleton', () {
      // Get two instances of NotificationService
      final service1 = NotificationService();
      final service2 = NotificationService();
      
      // Assert they are the same instance
      expect(identical(service1, service2), true);
    });
  });
}
