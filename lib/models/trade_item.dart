import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a study material available for trade in the shop
class TradeItem {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final int price;
  final Timestamp timestamp;

  TradeItem({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.price,
    required this.timestamp,
  });

  factory TradeItem.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // Fallback to now if serverTimestamp not yet set
    final ts = data['timestamp'] as Timestamp?;
    return TradeItem(
      id: doc.id,
      ownerId: data['ownerId'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      price: data['price'] as int,
      timestamp: ts ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'price': price,
      'timestamp': timestamp,
    };
  }
}
