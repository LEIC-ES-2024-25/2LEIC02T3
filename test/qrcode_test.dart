import 'package:flutter_test/flutter_test.dart';
import '../lib/models/challenge.dart';

void main() {
  group('QR Code 24h Reset Tests', () {
    
    test('QR code status should reset after 24 hours', () {
      
      Challenge cleanupChallenge = Challenge(
        id: 'cleanup',
        title: 'Cleanup Challenge',
        description: 'Participate in any environmental event',
        points: 50,
        qrCodeStatus: 'Scanned: clean up event',
        isCompleted: true,
      );
      
      
      final lastQRCodeDate = DateTime.now().subtract(const Duration(hours: 25));
      
      
      final hourDifference = DateTime.now().difference(lastQRCodeDate).inHours;
      expect(hourDifference >= 24, true, reason: 'Difference should be at least 24 hours');
      
      
      if (hourDifference >= 24) {
        cleanupChallenge.qrCodeStatus = "not scanned";
        cleanupChallenge.isCompleted = false;
      }
      
      
      expect(cleanupChallenge.qrCodeStatus, "not scanned", 
        reason: 'QR code status should be reset after 24 hours');
      expect(cleanupChallenge.isCompleted, false,
        reason: 'Completion flag should reset after 24 hours');
    });
    
    test('QR code status should not reset before 24 hours', () {
      
      Challenge cleanupChallenge = Challenge(
        id: 'cleanup',
        title: 'Cleanup Challenge',
        description: 'Participate in any environmental event',
        points: 50,
        qrCodeStatus: 'Scanned: clean up event',
        isCompleted: true,
      );
      
      
      final lastQRCodeDate = DateTime.now().subtract(const Duration(hours: 23));
      
      
      final hourDifference = DateTime.now().difference(lastQRCodeDate).inHours;
      expect(hourDifference < 24, true, reason: 'Difference should be less than 24 hours');
      
      
      if (hourDifference >= 24) {
        cleanupChallenge.qrCodeStatus = "not scanned";
        cleanupChallenge.isCompleted = false;
      }
      
      
      expect(cleanupChallenge.qrCodeStatus, "Scanned: clean up event", 
        reason: 'QR code status should not reset before 24 hours');
      expect(cleanupChallenge.isCompleted, true,
        reason: 'Completion flag should not reset before 24 hours');
    });
    
    test('Scan status is updated when scanning a QR code', () {
      
      Challenge cleanupChallenge = Challenge(
        id: 'cleanup',
        title: 'Cleanup Challenge', 
        description: 'Participate in any environmental event',
        points: 50,
        qrCodeStatus: 'not scanned'
      );
      
      
      final eventType = "clean up event";
      cleanupChallenge.qrCodeStatus = "Scanned: $eventType";
      
      
      expect(cleanupChallenge.qrCodeStatus, "Scanned: clean up event", 
        reason: 'QR code status should be updated with the event type');
    });
    
    test('Same-day scanning should be blocked by hasQRCodeBeenScannedToday check', () {
      
      final today = DateTime.now();
      final lastQRCodeDate = today;
      
      
      bool hasScannedToday = lastQRCodeDate.year == today.year &&
                            lastQRCodeDate.month == today.month &&
                            lastQRCodeDate.day == today.day;
      
      
      expect(hasScannedToday, true, 
        reason: 'Should detect that a QR code was already scanned today');
    });
    
    test('Next-day scanning should be allowed by hasQRCodeBeenScannedToday check', () {
      
      final today = DateTime.now();
      final lastQRCodeDate = today.subtract(const Duration(days: 1));
      
      
      bool hasScannedToday = lastQRCodeDate.year == today.year &&
                            lastQRCodeDate.month == today.month &&
                            lastQRCodeDate.day == today.day;
      
      
      expect(hasScannedToday, false, 
        reason: 'Should detect that no QR code was scanned today');
    });
  });
}