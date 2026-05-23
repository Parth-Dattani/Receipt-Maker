import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> updateLastReceiptNumber(int newRecNo) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await _db.collection('UserConfig').doc(uid).set({
      'lastRecNo': newRecNo,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<int> getLastReceiptNumber() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      var doc = await _db.collection('UserConfig').doc(uid).get();
      if (doc.exists && doc.data()!.containsKey('lastRecNo')) {
        return doc.get('lastRecNo');
      }
    } catch (e) {
      print("Error fetching last receipt number: $e");
    }
    return 0;
  }

  // 🚀 Donation Types Management
  static Future<List<String>> getDonationTypes() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      var doc = await _db.collection('UserConfig').doc(uid).get();
      if (doc.exists && doc.data()!.containsKey('donationTypes')) {
        List<dynamic> types = doc.get('donationTypes');
        return types.map((e) => e.toString()).toList();
      }
    } catch (e) {
      print("Error fetching donation types: $e");
    }
    return ['General']; // Default fallback
  }

  static Future<void> addDonationType(String newType) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await _db.collection('UserConfig').doc(uid).update({
      'donationTypes': FieldValue.arrayUnion([newType.trim()]),
    });
  }

  static Future<void> removeDonationType(String type) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await _db.collection('UserConfig').doc(uid).update({
      'donationTypes': FieldValue.arrayRemove([type]),
    });
  }
}
