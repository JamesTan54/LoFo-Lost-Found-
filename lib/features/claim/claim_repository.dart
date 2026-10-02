import 'package:cloud_firestore/cloud_firestore.dart';

class ClaimRepository {
  final FirebaseFirestore _firestore;

  ClaimRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Mengambil detail barang dari Firestore
  Future<Map<String, dynamic>?> getItemDetails(String itemId) async {
    if (itemId.isEmpty) return null;
    final doc = await _firestore.collection('items').doc(itemId).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return doc.data();
  }

  // Menyimpan data pengajuan klaim ke Firestore
  Future<void> submitClaim({
    required String itemId,
    required String claimantName,
    required String claimantPhone,
    required String reason,
  }) async {
    await _firestore.collection('claims').add({
      'itemId': itemId,
      'claimantName': claimantName,
      'claimantPhone': claimantPhone,
      'reason': reason,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}