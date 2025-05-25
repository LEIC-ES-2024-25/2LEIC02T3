import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/trade_item.dart';

class TradeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  
  Stream<List<TradeItem>> getAvailableItems() {
    final currentUser = _auth.currentUser;
    return _firestore.collection('trade_items')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snap) => snap.docs
          .map((doc) => TradeItem.fromDoc(doc))
          .where((item) => item.ownerId != currentUser?.uid)
          .toList());
  }

  
  Future<void> addTradeItem(String title, String description, int price) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');
    await _firestore.collection('trade_items').add({
      'ownerId': user.uid,
      'title': title,
      'description': description,
      'price': price,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  
  Future<void> buyItem(TradeItem item) async {
    await _firestore.collection('trade_items').doc(item.id).delete();
  }

  
  Stream<List<TradeItem>> getMyItems() {
    final user = _auth.currentUser;
    if (user == null) {
      
      return Stream.value([]);
    }
    return _firestore
      .collection('trade_items')
      .where('ownerId', isEqualTo: user.uid)
      .snapshots()
      .map((snap) {
        final items = snap.docs.map((doc) => TradeItem.fromDoc(doc)).toList();
        
        items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return items;
      });
  }
}
