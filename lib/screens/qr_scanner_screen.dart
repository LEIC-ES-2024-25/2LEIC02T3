import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/points_provider.dart';
import 'bottom_navigation_bar.dart';
import '../providers/badges_provider.dart';

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
    try {
      final parts = code.split(' ');
      if (parts.length < 2) {
        _showErrorMessage('QR Code inválido. Formato: "tipo_evento AAAA-MM-DD"');
        return;
      }
      final eventType = parts[0];
      final eventDateStr = parts[1];
      late DateTime parsedDate;
      try {
        parsedDate = DateTime.parse(eventDateStr);
      } catch (_) {
        _showErrorMessage('Formato de data inválido no QR Code');
        return;
      }
      final today = DateTime.now();
      if (parsedDate.isBefore(today) && !_isSameDay(parsedDate, today)) {
        _showErrorMessage('Este QR Code é para um evento passado');
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      final key = '${eventType}_${parsedDate.year}-${parsedDate.month}-${parsedDate.day}_${today.year}-${today.month}-${today.day}';
      if (prefs.getBool(key) ?? false) {
        _showErrorMessage('Você já escaneou este QR Code hoje!');
        return;
      }
      final points = _calculatePoints(eventType);
      await Provider.of<PointsProvider>(context, listen: false).addPoints(points);
      await prefs.setBool(key, true);
      // Unlock badge related to this event
      final badgesProvider = Provider.of<BadgesProvider>(context, listen: false);
      await badgesProvider.unlockBadge(eventType, context);
      _showSuccessMessage('Parabéns! Você ganhou $points pontos.');
    } catch (e) {
      _showErrorMessage('Erro ao processar QR Code: $e');
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int _calculatePoints(String eventType) {
    const eventPoints = {
      'clean|up|event': 50,
      'eco|friendly|market': 30,
      'sustainable|food|festival': 40,
      'tree|planting|event': 60,
      'bicycle|parade': 25,
      'group|walk|event': 20,
      'play|a|sport|event': 15,
      'car|free|day|meet|up': 35,
      'car|pool': 30,
      'local|commerce': 20,
      'thrift|store': 25,
      'public|transport': 15,
    };
    return eventPoints[eventType] ?? 10;
  }

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
            child: MobileScanner(
              controller: controller,
              onDetect: _onDetect,
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
    ); // end Scaffold
  } // end build
} // end _QRScannerScreenState and QRScannerScreen