import 'package:flutter_test/flutter_test.dart';
import '../lib/services/notification_service.dart';

void main() {
  group('Notification Tests', () {
    test('NotificationService should be a singleton', () {
      
      final service1 = NotificationService();
      final service2 = NotificationService();
      
      
      expect(identical(service1, service2), true);
    });
  });
}
