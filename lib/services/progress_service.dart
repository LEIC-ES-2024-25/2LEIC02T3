import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> setUserProgress(Map<String, dynamic> progressData) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');
    await _firestore.collection('user_progress').doc(user.uid).set(progressData, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserProgress() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');
    final doc = await _firestore.collection('user_progress').doc(user.uid).get();
    return doc.exists ? doc.data() : null;
  }
}
