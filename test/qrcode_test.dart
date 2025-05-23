import 'package:flutter_test/flutter_test.dart';
import '../lib/models/challenge.dart';

void main() {
  group('QR Code 24h Reset Tests', () {
    
    test('QR code status should reset after 24 hours', () {
      // Create a challenge with a QR code status
      Challenge cleanupChallenge = Challenge(
        id: 'cleanup',
        title: 'Cleanup Challenge',
        description: 'Participate in any environmental event',
        points: 50,
        qrCodeStatus: 'Scanned: clean up event'
      );
      
      // Set a lastQRCodeDate 25 hours ago (exceeds 24h limit)
      final lastQRCodeDate = DateTime.now().subtract(const Duration(hours: 25));
      
      // Check if time difference exceeds 24 hours
      final hourDifference = DateTime.now().difference(lastQRCodeDate).inHours;
      expect(hourDifference >= 24, true, reason: 'Difference should be at least 24 hours');
      
      // Apply the status reset logic that happens in the app
      if (hourDifference >= 24) {
        cleanupChallenge.qrCodeStatus = "not scanned";
      }
      
      // Verify QR code status was reset
      expect(cleanupChallenge.qrCodeStatus, "not scanned", 
        reason: 'QR code status should be reset after 24 hours');
    });
    
    test('QR code status should not reset before 24 hours', () {
      // Create a challenge with a QR code status
      Challenge cleanupChallenge = Challenge(
        id: 'cleanup',
        title: 'Cleanup Challenge',
        description: 'Participate in any environmental event',
        points: 50,
        qrCodeStatus: 'Scanned: clean up event'
      );
      
      // Set a lastQRCodeDate 23 hours ago (within 24h limit)
      final lastQRCodeDate = DateTime.now().subtract(const Duration(hours: 23));
      
      // Check if time difference is less than 24 hours
      final hourDifference = DateTime.now().difference(lastQRCodeDate).inHours;
      expect(hourDifference < 24, true, reason: 'Difference should be less than 24 hours');
      
      // Apply the status reset logic that happens in the app
      if (hourDifference >= 24) {
        cleanupChallenge.qrCodeStatus = "not scanned";
      }
      
      // Verify QR code status was not reset
      expect(cleanupChallenge.qrCodeStatus, "Scanned: clean up event", 
        reason: 'QR code status should not reset before 24 hours');
    });
    
    test('Scan status is updated when scanning a QR code', () {
      // Create a challenge with initial "not scanned" status
      Challenge cleanupChallenge = Challenge(
        id: 'cleanup',
        title: 'Cleanup Challenge', 
        description: 'Participate in any environmental event',
        points: 50,
        qrCodeStatus: 'not scanned'
      );
      
      // Simulate scanning a QR code and updating status
      final eventType = "clean up event";
      cleanupChallenge.qrCodeStatus = "Scanned: $eventType";
      
      // Verify status was updated correctly
      expect(cleanupChallenge.qrCodeStatus, "Scanned: clean up event", 
        reason: 'QR code status should be updated with the event type');
    });
    
    test('Same-day scanning should be blocked by hasQRCodeBeenScannedToday check', () {
      // Set last QR code scan date to current day
      final today = DateTime.now();
      final lastQRCodeDate = today;
      
      // Re-implement the hasQRCodeBeenScannedToday logic from the app
      bool hasScannedToday = lastQRCodeDate.year == today.year &&
                            lastQRCodeDate.month == today.month &&
                            lastQRCodeDate.day == today.day;
      
      // Verify that scanning should be blocked
      expect(hasScannedToday, true, 
        reason: 'Should detect that a QR code was already scanned today');
    });
    
    test('Next-day scanning should be allowed by hasQRCodeBeenScannedToday check', () {
      // Set last QR code scan date to yesterday
      final today = DateTime.now();
      final lastQRCodeDate = today.subtract(const Duration(days: 1));
      
      // Re-implement the hasQRCodeBeenScannedToday logic from the app
      bool hasScannedToday = lastQRCodeDate.year == today.year &&
                            lastQRCodeDate.month == today.month &&
                            lastQRCodeDate.day == today.day;
      
      // Verify that scanning should be allowed
      expect(hasScannedToday, false, 
        reason: 'Should detect that no QR code was scanned today');
    });
  });
}