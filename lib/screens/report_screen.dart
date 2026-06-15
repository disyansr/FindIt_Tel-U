import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/item_model.dart';
import '../viewmodels/item_viewmodel.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descController = TextEditingController();
  final _contactController = TextEditingController();
  final _dateController = TextEditingController();

  String _selectedStatus = 'Hilang';
  XFile? _pickedImage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descController.dispose();
    _contactController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd MMMM yyyy').format(picked);
      });
    }
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _pickedImage = image);
  }

  Future<void> _submitReport() async {
    if (_titleController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _contactController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua kolom wajib diisi!')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    final newItem = ItemModel(
      title: _titleController.text,
      location: _locationController.text,
      description: _descController.text,
      status: _selectedStatus,
      date: _dateController.text,
      contact: _contactController.text,
      imageUrl: _pickedImage != null
          ? _pickedImage!.path
          : 'https://images.unsplash.com/photo-1594322436404-5a0526db4d13?q=80&w=400',
      reportedBy: uid,
    );

    final success = await context.read<ItemViewModel>().addItem(newItem);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      _titleController.clear();
      _locationController.clear();
      _descController.clear();
      _contactController.clear();
      _dateController.clear();
      setState(() => _pickedImage = null);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan berhasil dikirim!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengirim laporan. Coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lapor Barang',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Foto Barang',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: _pickedImage == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo,
                              size: 40, color: Colors.grey),
                          Text('Upload Foto'),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: kIsWeb
                            ? Image.network(_pickedImage!.path,
                                fit: BoxFit.cover)
                            : Image.file(File(_pickedImage!.path),
                                fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              items: ['Hilang', 'Ditemukan']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedStatus = val!),
              decoration: const InputDecoration(
                  labelText: 'Status', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                  labelText: 'Nama Barang', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                  labelText: 'Lokasi', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _dateController,
              readOnly: true,
              onTap: _selectDate,
              decoration: const InputDecoration(
                labelText: 'Tanggal Kejadian',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _contactController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Nomor WhatsApp',
                hintText: 'Contoh: 0812345678',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                  labelText: 'Deskripsi Detail',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB71C1C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('KIRIM LAPORAN',
                        style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}