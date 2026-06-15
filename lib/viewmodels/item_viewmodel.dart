import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/item_model.dart';

class ItemViewModel extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  // Stream semua laporan (Home Screen)
  Stream<List<ItemModel>> get itemsStream => _service.getItems();

  // Stream laporan milik user tertentu (Riwayat Screen)
  Stream<List<ItemModel>> getUserItemsStream(String uid) =>
      _service.getUserItems(uid);

  // Tambah laporan baru
  Future<bool> addItem(ItemModel item) async {
    try {
      await _service.addItem(item);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Hapus laporan
  Future<bool> deleteItem(String id) async {
    try {
      await _service.deleteItem(id);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Update status barang
  Future<bool> updateStatus(String id, String newStatus) async {
    try {
      await _service.updateStatus(id, newStatus);
      return true;
    } catch (e) {
      return false;
    }
  }
}