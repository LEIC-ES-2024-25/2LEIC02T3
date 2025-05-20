import 'package:flutter/material.dart';
import 'bottom_navigation_bar.dart';
import '../widgets/points_tracker.dart';
import '../providers/points_provider.dart';
import 'package:provider/provider.dart';
import '../services/trade_service.dart';
import '../models/trade_item.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final _tradeService = TradeService();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  bool _showMyItems = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: PointsTracker(),
          ),
        ],
      ),
      body: Consumer<PointsProvider>(
        builder: (context, pointsProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Toggle between available items and my items
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !_showMyItems ? Colors.green : Colors.grey[300],
                        ),
                        onPressed: () => setState(() => _showMyItems = false),
                        child: Text(
                          'Available',
                          style: TextStyle(
                            color: !_showMyItems ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _showMyItems ? Colors.green : Colors.grey[300],
                        ),
                        onPressed: () => setState(() => _showMyItems = true),
                        child: Text(
                          'My Items',
                          style: TextStyle(
                            color: _showMyItems ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // If showing my items, display add form
                if (_showMyItems) ...[
                  const Text(
                    'Add Item to Trade',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price (points)'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final title = _titleController.text.trim();
                      final description = _descriptionController.text.trim();
                      final price = int.tryParse(_priceController.text) ?? 0;
                      if (title.isNotEmpty && description.isNotEmpty && price > 0) {
                        try {
                          await _tradeService.addTradeItem(title, description, price);
                          _titleController.clear();
                          _descriptionController.clear();
                          _priceController.clear();
                          // Switch to My Items view to display the new listing
                          setState(() => _showMyItems = true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Item added for trade'), 
                            backgroundColor: Colors.green,)
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to add item: $e'),
                            backgroundColor: Colors.green,)
                          );
                        }
                      }
                    },
                    child: const Text('Add Item'),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'My Items',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                ],
                // Header for available items when not in my items mode
                if (!_showMyItems) ...[
                  const Text(
                    'Available Items',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                ],
                // List of trade items
                Expanded(
                  child: StreamBuilder<List<TradeItem>>(
                    stream: _showMyItems
                        ? _tradeService.getMyItems()
                        : _tradeService.getAvailableItems(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final items = snapshot.data ?? [];
                      if (items.isEmpty) {
                        return Center(child: Text(_showMyItems
                            ? 'You have no items listed.'
                            : 'No items available'));
                      }
                      return ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(item.title),
                              subtitle: Text(item.description),
                              trailing: _showMyItems
                                  // Show delete button for my items
                                  ? IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () async {
                                        await _tradeService.buyItem(item);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Item removed'),
                                          backgroundColor: Colors.green,)
                                        );
                                      },
                                    )
                                  // Purchase button for available items
                                  : ElevatedButton(
                                      onPressed: pointsProvider.points >= item.price
                                          ? () {
                                              showDialog(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: const Text('Confirm Purchase'),
                                                  content: Text('Buy "${item.title}" for ${item.price} pts?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.of(ctx).pop(),
                                                      child: const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        Navigator.of(ctx).pop();
                                                        try {
                                                          await _tradeService.buyItem(item);
                                                          await pointsProvider.removePoints(item.price);
                                                          // Refresh UI to remove the purchased item
                                                          setState(() {});
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(content: Text('Purchased "${item.title}" for ${item.price} pts'),
                                                            backgroundColor: Colors.green,)
                                                          );
                                                        } catch (e) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(content: Text('Purchase failed: $e'),
                                                            backgroundColor: Colors.green,)
                                                            );
                                                        }
                                                      },
                                                      child: const Text('Buy'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                          : null,
                                      child: Text('${item.price} pts'),
                                    ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        currentScreen: 'ShopScreen',
      ),
    );
  }
}