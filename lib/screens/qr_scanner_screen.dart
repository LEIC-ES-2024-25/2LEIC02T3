import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'bottom_navigation_bar.dart';
import '../providers/badges_provider.dart';
import '../providers/challenges_provider.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isScanning = true;
  bool _showSuccess = false;
  bool _showError = false;
  String _resultMessage = '';

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;
    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final code = barcodes.first.rawValue ?? '';
      setState(() => _isScanning = false);
      _processQRCode(code);
    }
  }

  Future<void> _processQRCode(String code) async {
    
    final challengesProvider = Provider.of<ChallengesProvider>(context, listen: false);
    if (await challengesProvider.hasQRCodeBeenScannedToday()) {
      _showErrorMessage('You have already scanned a QR code today! Please try again tomorrow.');
      return;
    }
    try {
      final parts = code.split(' ');
      if (parts.length < 2) {
        _showErrorMessage('Invalid QR code. Format: "eventType YYYY-MM-DD"');
        return;
      }      final eventType = parts[0];
      final eventDateStr = parts[1];
      late DateTime parsedDate;
      try {
        
        if (eventDateStr.split('-').length == 3) {
          final dateParts = eventDateStr.split('-');
          if (dateParts.length == 3) {
            final year = int.parse(dateParts[0]);
            final month = int.parse(dateParts[1]);
            final day = int.parse(dateParts[2]);
            parsedDate = DateTime(year, month, day);
          } else {
            parsedDate = DateTime.parse(eventDateStr);
          }
        } else {
          parsedDate = DateTime.parse(eventDateStr);
        }
      } catch (e) {
        _showErrorMessage('Invalid date in QR code: $eventDateStr. Format expected: YYYY-MM-DD');
        return;
      }
      final today = DateTime.now();
      if (parsedDate.isBefore(today) && !_isSameDay(parsedDate, today)) {
        _showErrorMessage('This QR code is for a past event');
        return;
      }      
      final badgesProvider = Provider.of<BadgesProvider>(context, listen: false);
      await badgesProvider.unlockBadge(eventType, context);

      
      await challengesProvider.updateQRCodeStatus(eventType.replaceAll('|', ' '));
      
      await challengesProvider.markQRCodeScannedToday();
      
      
      await challengesProvider.completeChallenge('cleanup', context);
        
      if (eventType == 'bicycle|parade' || eventType == 'car|pool') {
        await challengesProvider.completeChallenge('bike', context);
      } else if (eventType == 'car|free|day|meet|up') {
        await challengesProvider.completeChallenge('car-free', context);
      }
      
      _showSuccessMessage('Parabéns! QR code escaneado com sucesso!');
      
      
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      _showErrorMessage('Erro ao processar QR Code: $e');
    }
  }
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;


  void _showSuccessMessage(String msg) => setState(() {
        _showSuccess = true;
        _showError = false;
        _resultMessage = msg;
      });

  void _showErrorMessage(String msg) => setState(() {
        _showSuccess = false;
        _showError = true;
        _resultMessage = msg;
      });

  void _resetScanner() => setState(() {
        _isScanning = true;
        _showSuccess = false;
        _showError = false;
        _resultMessage = '';
      });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.green.shade800,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isScanning 
              ? MobileScanner(
                  controller: controller,
                  onDetect: _onDetect,
                )
              : Container(
                  color: Colors.white,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          size: 100,
                          color: Colors.green.shade300,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'QR Code Processed',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
          if (_showSuccess || _showError)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _resultMessage,
                style: TextStyle(
                  color: _showSuccess ? Colors.green : Colors.red,
                ),
              ),
            ),
          if (!_isScanning)
            ElevatedButton(
              onPressed: _resetScanner,
              child: const Text('Scan Again'),
            ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        currentScreen: 'QRScannerScreen',
      ),
    ); 
  } 
} 