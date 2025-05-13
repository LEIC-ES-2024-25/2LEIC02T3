import 'package:flutter/material.dart';
import '../models/trade_request.dart';

class TradeRequestsProvider with ChangeNotifier {
  final List<TradeRequest> _tradeRequests = [];

  List<TradeRequest> get tradeRequests => [..._tradeRequests];

  void addTradeRequest(TradeRequest tradeRequest) {
    _tradeRequests.add(tradeRequest);
    notifyListeners();
  }

  void acceptTradeRequest(String id) {
    _tradeRequests.removeWhere((request) => request.id == id);
    notifyListeners();
  }
}