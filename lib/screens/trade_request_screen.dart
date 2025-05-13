import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trade_requests_provider.dart';

class TradeRequestScreen extends StatelessWidget {
  const TradeRequestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tradeRequestsProvider = Provider.of<TradeRequestsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trade Requests'),
      ),
      body: ListView.builder(
        itemCount: tradeRequestsProvider.tradeRequests.length,
        itemBuilder: (context, index) {
          final tradeRequest = tradeRequestsProvider.tradeRequests[index];
          return ListTile(
            title: Text(tradeRequest.materialTitle),
            subtitle: Text('Requested by: ${tradeRequest.requesterName}'),
            trailing: IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                tradeRequestsProvider.acceptTradeRequest(tradeRequest.id);
              },
            ),
          );
        },
      ),
    );
  }
}