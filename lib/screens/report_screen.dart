import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
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
  bool _isUploading = false;

  final String _cloudName = 'dfvavwvta';
  final String _uploadPreset = 'findit_telu';

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
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image != null) setState(() => _pickedImage = image);
  }

  Future<String?> _uploadToCloudinary() async {
    if (_pickedImage == null) return null;

    setState(() => _isUploading = true);

    try {
      final url = Uri.parse(
          'https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

      final request = http.MultipartRequest('POST', url);
      request.fields['upload_preset'] = _uploadPreset;

      if (kIsWeb) {
        final bytes = await _pickedImage!.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: _pickedImage!.name,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          _pickedImage!.path,
        ));
      }

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final jsonData = jsonDecode(String.fromCharCodes(responseData));

      return jsonData['secure_url'];
    } catch (e) {
      return null;
    } finally {
      setState(() => _isUploading = false);
    }
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

    // Simpan reference sebelum async gap
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final itemViewModel = context.read<ItemViewModel>();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    String imageUrl =
        'https://images.unsplash.com/photo-1594322436404-5a0526db4d13?q=80&w=400';

    if (_pickedImage != null) {
      final uploadedUrl = await _uploadToCloudinary();
      if (uploadedUrl != null) {
        imageUrl = uploadedUrl;
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Gagal upload foto, pakai foto default.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }

    final newItem = ItemModel(
      title: _titleController.text,
      location: _locationController.text,
      description: _descController.text,
      status: _selectedStatus,
      date: _dateController.text,
      contact: _contactController.text,
      imageUrl: imageUrl,
      reportedBy: uid,
    );

    final success = await itemViewModel.addItem(newItem);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      _titleController.clear();
      _locationController.clear();
      _descController.clear();
      _contactController.clear();
      _dateController.clear();
      setState(() => _pickedImage = null);

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Laporan berhasil dikirim!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(
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
              onTap: _isSubmitting ? null : _pickImage,
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
                          SizedBox(height: 8),
                          Text('Upload Foto',
                              style: TextStyle(color: Colors.grey)),
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
                  .map((s) =>
                      DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) =>
                  setState(() => _selectedStatus = val!),
              decoration: const InputDecoration(
                  labelText: 'Status', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                  labelText: 'Nama Barang',
                  border: OutlineInputBorder()),
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
                onPressed: _isSubmitting || _isUploading
                    ? null
                    : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB71C1C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: _isUploading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          ),
                          SizedBox(width: 10),
                          Text('Mengupload foto...',
                              style: TextStyle(color: Colors.white)),
                        ],
                      )
                    : _isSubmitting
                        ? const CircularProgressIndicator(
                            color: Colors.white)
                        : const Text('KIRIM LAPORAN',
                            style: TextStyle(
                                fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}