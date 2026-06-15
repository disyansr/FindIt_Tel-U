import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _col = 'items';

  // CREATE
  Future<void> addItem(ItemModel item) async {
    final data = item.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    await _db.collection(_col).add(data);
  }

  // READ — semua laporan (Home Screen)
  Stream<List<ItemModel>> getItems() {
    return _db
        .collection(_col)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ItemModel.fromMap(d.data(), d.id)).toList());
  }

  // READ — laporan milik user tertentu (Riwayat Screen)
  Stream<List<ItemModel>> getUserItems(String uid) {
    return _db
        .collection(_col)
        .where('reportedBy', isEqualTo: uid)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ItemModel.fromMap(d.data(), d.id)).toList());
  }

  // UPDATE — ubah status barang
  Future<void> updateStatus(String id, String newStatus) async {
    await _db.collection(_col).doc(id).update({'status': newStatus});
  }

  // DELETE
  Future<void> deleteItem(String id) async {
    await _db.collection(_col).doc(id).delete();
  }
}