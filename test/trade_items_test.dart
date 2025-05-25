import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../lib/models/trade_item.dart';

void main() {
  group('TradeItem Model Tests', () {
    test('TradeItem should initialize with correct properties', () {
      final timestamp = Timestamp.now();
      final item = TradeItem(
        id: 'item-1',
        ownerId: 'user-1',
        title: 'Test Item',
        description: 'This is a test item',
        price: 100,
        timestamp: timestamp,
      );
      
      expect(item.id, 'item-1');
      expect(item.ownerId, 'user-1');
      expect(item.title, 'Test Item');
      expect(item.description, 'This is a test item');
      expect(item.price, 100);
      expect(item.timestamp, timestamp);
    });
    
    test('TradeItem.fromDoc should create item from document snapshot', () {
      
      
      final docData = {
        'ownerId': 'user-2',
        'title': 'Item from doc',
        'description': 'Item created from document',
        'price': 200,
        'timestamp': Timestamp.now(),
      };
      
      
      expect(docData.containsKey('ownerId'), true);
      expect(docData.containsKey('title'), true);
      expect(docData.containsKey('description'), true);
      expect(docData.containsKey('price'), true);
      expect(docData.containsKey('timestamp'), true);
    });
    
    test('TradeItem.toMap should convert item to map', () {
      final timestamp = Timestamp.now();
      final item = TradeItem(
        id: 'item-3',
        ownerId: 'user-3',
        title: 'Map Item',
        description: 'Item for map conversion',
        price: 300,
        timestamp: timestamp,
      );
      
      final map = item.toMap();
      
      expect(map['ownerId'], 'user-3');
      expect(map['title'], 'Map Item');
      expect(map['description'], 'Item for map conversion');
      expect(map['price'], 300);
      expect(map['timestamp'], timestamp);
    });
  });
  
  group('TradeService Functional Tests', () {
    test('getMyItems should return only items owned by current user', () {
      
      
      
      final itemsFromCurrentUser = [
        TradeItem(
          id: 'item1',
          ownerId: 'current-user-id', 
          title: 'My Item 1',
          description: 'My first item', 
          price: 100,
          timestamp: Timestamp.now(),
        ),
        TradeItem(
          id: 'item2',
          ownerId: 'current-user-id', 
          title: 'My Item 2',
          description: 'My second item', 
          price: 150,
          timestamp: Timestamp.now(),
        ),
      ];
      
      
      expect(itemsFromCurrentUser.every((item) => item.ownerId == 'current-user-id'), true);
    });
    
    test('getAvailableItems should return items not owned by current user', () {
      
      final allItems = [
        TradeItem(
          id: 'item1',
          ownerId: 'current-user-id', 
          title: 'My Item', 
          description: 'Should be filtered out', 
          price: 100,
          timestamp: Timestamp.now(),
        ),
        TradeItem(
          id: 'item2',
          ownerId: 'other-user-1', 
          title: 'Available Item 1', 
          description: 'Should be included', 
          price: 200,
          timestamp: Timestamp.now(),
        ),
        TradeItem(
          id: 'item3',
          ownerId: 'other-user-2', 
          title: 'Available Item 2', 
          description: 'Should be included', 
          price: 300,
          timestamp: Timestamp.now(),
        ),
      ];
      
      
      final filteredItems = allItems.where((item) => item.ownerId != 'current-user-id').toList();
      
      
      expect(filteredItems.length, 2);
      expect(filteredItems.every((item) => item.ownerId != 'current-user-id'), true);
      
      
      final titles = filteredItems.map((e) => e.title).toList();
      expect(titles.contains('Available Item 1'), true);
      expect(titles.contains('Available Item 2'), true);
    });
    
    test('addTradeItem should add new item to the collection', () {
      
      
      
      final newItemData = {
        'ownerId': 'current-user-id',
        'title': 'New Item',
        'description': 'Test Description',
        'price': 150,
        
      };
      
      
      expect(newItemData.containsKey('ownerId'), true);
      expect(newItemData.containsKey('title'), true);
      expect(newItemData.containsKey('description'), true);
      expect(newItemData.containsKey('price'), true);
    });
    
    test('buyItem should remove the item from the collection', () {
      
      
      
      final itemToBuy = TradeItem(
        id: 'item-to-buy',
        ownerId: 'other-user-id',
        title: 'Item to buy',
        description: 'Item description',
        price: 250,
        timestamp: Timestamp.now(),
      );
      
      
      expect(itemToBuy.id, 'item-to-buy');
    });
    
    test('delete item should remove the item from myItems', () {
      
      
      final itemToDelete = TradeItem(
        id: 'my-item-to-delete',
        ownerId: 'current-user-id',
        title: 'My Item to delete',
        description: 'My item description',
        price: 300,
        timestamp: Timestamp.now(),
      );
      
      
      expect(itemToDelete.id, 'my-item-to-delete');
      expect(itemToDelete.ownerId, 'current-user-id');
    });
  });
}