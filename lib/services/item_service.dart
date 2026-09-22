import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ItemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future addItem({
    required String title,
    required String description,
    required String location,
    required String type,
    String? contactPhone, // <--- TAMBAHAN
    Uint8List? imageBytes,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User belum login');

    String? base64Image;
    if (imageBytes != null) {
      base64Image = base64Encode(imageBytes);
    }

    await _firestore.collection('items').add({
      'title': title,
      'description': description,
      'location': location,
      'type': type,
      'contactPhone': contactPhone, // <--- TAMBAHAN
      'imageUrl': base64Image,
      'userId': user.uid,
      'userEmail': user.email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream getItems() {
    return _firestore
        .collection('items')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream getUserItems() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('items')
        .where('userId', isEqualTo: user.uid)
        .snapshots();
  }

  Future deleteItem(String docId) async {
    await _firestore.collection('items').doc(docId).delete();
  }
}