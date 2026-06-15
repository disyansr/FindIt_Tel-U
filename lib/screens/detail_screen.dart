import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/item_model.dart';
import '../viewmodels/item_viewmodel.dart';

class DetailScreen extends StatelessWidget {
  final ItemModel item;

  const DetailScreen({super.key, required this.item});

  Future<void> _openWhatsApp(String phone) async {
    final number = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final formatted =
        number.startsWith('0') ? '62${number.substring(1)}' : number;
    final url = Uri.parse('https://wa.me/$formatted');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = item.reportedBy == currentUid;
    final isHilang = item.status == 'Hilang';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Barang',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
        actions: isOwner
            ? [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) async {
                    if (value == 'status') {
                      final newStatus = isHilang ? 'Ditemukan' : 'Hilang';
                      await context
                          .read<ItemViewModel>()
                          .updateStatus(item.id!, newStatus);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Status diubah ke "$newStatus"'),
                            backgroundColor: Colors.blue,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    } else if (value == 'hapus') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Hapus Laporan'),
                          content: const Text(
                              'Yakin ingin menghapus laporan ini?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Hapus',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && context.mounted) {
                        await context
                            .read<ItemViewModel>()
                            .deleteItem(item.id!);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Laporan berhasil dihapus'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          Navigator.pop(context);
                        }
                      }
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'status',
                      child: Row(
                        children: [
                          Icon(
                            Icons.swap_horiz,
                            color: isHilang ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isHilang
                                ? 'Tandai Ditemukan'
                                : 'Tandai Hilang',
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'hapus',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus Laporan',
                              style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar menyesuaikan ukuran asli
            Container(
              width: double.infinity,
              color: Colors.black87,
              constraints: const BoxConstraints(
                minHeight: 200,
                maxHeight: 400,
              ),
              child: Image.network(
                item.imageUrl,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_not_supported,
                          size: 60, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Foto tidak tersedia',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isHilang
                          ? Colors.red[700]
                          : Colors.green[700],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Color(0xFFB71C1C), size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.location,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Color(0xFFB71C1C), size: 22),
                      const SizedBox(width: 8),
                      Text(
                        item.date,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(thickness: 1),
                  ),
                  const Text(
                    'Deskripsi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.description.isEmpty
                        ? 'Tidak ada deskripsi.'
                        : item.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Hubungi Pemilik/Penemu:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openWhatsApp(item.contact),
                      icon: const Icon(Icons.chat, color: Colors.white),
                      label: Text(
                        'Chat via WhatsApp (${item.contact})',
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}