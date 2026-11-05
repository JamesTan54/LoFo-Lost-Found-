import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../routes/app_routes.dart';
import '../services/notification_service.dart';
import '../services/camera_service.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();

  final int _currentIndex = 1;

  // Form Field Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final CameraService _cameraService = CameraService();
  XFile? _selectedImage;

  String _reportType = 'Barang Hilang';
  bool _isLoading = false;

  void _onItemTapped(int index) {
    if (index == _currentIndex || _isLoading) return;

    if (index == 0) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, AppRoutes.myReports);
    }
  }

  // =========================================================
  // POP-UP NOTIFIKASI DI ATAS (Warna bertema Home: #3D2314 & #C87038)
  // =========================================================
  void _showTopNotification({required String title, required String message}) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF3D2314), // Warna Header Home
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFC87038), // Warna Accent Utama
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_outline, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: TextStyle(
                          color: Colors.grey.shade300,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Otomatis menutup notifikasi setelah 3.5 detik
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  Future<void> _takePicture() async {
    try {
      final image = await _cameraService.takePhoto();
      if (image != null) {
        setState(() {
          _selectedImage = image;
          _imageUrlController.text = image.path;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengakses kamera: $e')),
      );
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu.')),
      );
      return;
    }

    // Aktifkan Loading State
    setState(() => _isLoading = true);

    final titleText = _titleController.text.trim();
    final locationText = _locationController.text.trim();

    try {
      // Simpan Data ke Firestore
      await FirebaseFirestore.instance.collection('reports').add({
        'userId': user.uid,
        'type': _reportType,
        'title': titleText,
        'location': locationText,
        'phone': _phoneController.text.trim(),
        'imageUrl': _imageUrlController.text.trim(),
        'description': _descriptionController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Pemicu Notifikasi Sistem Lokal (Safety Catch)
      NotificationService.showNotification(
        title: 'Laporan Berhasil Dibuat! 📢',
        body: 'Barang "$titleText" di $locationText telah tercatat.',
      );

      // Tampilkan Pop-Up Notifikasi di Atas Layar (Custom UI)
      if (mounted) {
        _showTopNotification(
          title: 'Laporan Berhasil Dibuat! 📢',
          message: 'Barang "$titleText" di $locationText telah dicatat di sistem LoFo.',
        );
      }

      // Reset Form Input
      _titleController.clear();
      _locationController.clear();
      _phoneController.clear();
      _imageUrlController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedImage = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan laporan: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F5),
      appBar: AppBar(
        title: const Text('Tambah Laporan Barang'),
        backgroundColor: const Color(0xFF3D2314),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jenis Laporan',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 8),

                      // Tombol Pilihan Jenis Laporan
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : () => setState(() => _reportType = 'Barang Hilang'),
                              icon: _reportType == 'Barang Hilang'
                                  ? const Icon(Icons.check, color: Colors.red, size: 18)
                                  : const SizedBox.shrink(),
                              label: Text(
                                'Barang Hilang',
                                style: TextStyle(
                                  color: _reportType == 'Barang Hilang' ? Colors.red : Colors.black87,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: _reportType == 'Barang Hilang'
                                    ? Colors.red.shade50
                                    : Colors.white,
                                side: BorderSide(
                                  color: _reportType == 'Barang Hilang'
                                      ? Colors.red
                                      : Colors.grey.shade300,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => setState(() => _reportType = 'Barang Ditemukan'),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: _reportType == 'Barang Ditemukan'
                                    ? Colors.green.shade50
                                    : Colors.white,
                                side: BorderSide(
                                  color: _reportType == 'Barang Ditemukan'
                                      ? Colors.green
                                      : Colors.grey.shade300,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Barang Ditemukan',
                                style: TextStyle(
                                  color: _reportType == 'Barang Ditemukan' ? Colors.green : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Input Nama Barang
                      TextFormField(
                        controller: _titleController,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.shopping_bag_outlined),
                          hintText: 'Nama Barang',
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Nama barang wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),

                      // Input Lokasi
                      TextFormField(
                        controller: _locationController,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          hintText: 'Lokasi Ditemukan / Hilang di Kampus',
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Lokasi wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),

                      // Input No HP
                      TextFormField(
                        controller: _phoneController,
                        enabled: !_isLoading,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.phone_outlined),
                          hintText: 'Nomor Telepon / WhatsApp',
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Nomor telepon wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),

                      // Input URL Gambar & Tombol Kamera
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _imageUrlController,
                              enabled: !_isLoading,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.image_outlined),
                                hintText: 'URL Gambar (Opsional)',
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _takePicture,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC87038),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Icon(Icons.camera_alt),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Box Pratinjau Gambar
                      Container(
                        width: double.infinity,
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: kIsWeb
                                    ? Image.network(_selectedImage!.path, fit: BoxFit.cover)
                                    : Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                              )
                            : _imageUrlController.text.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      _imageUrlController.text,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Center(
                                        child: Text('Gagal memuat URL gambar'),
                                      ),
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text(
                                        'Pratinjau foto kamera / URL akan muncul di sini',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                      ),
                      const SizedBox(height: 12),

                      // Input Deskripsi
                      TextFormField(
                        controller: _descriptionController,
                        enabled: !_isLoading,
                        maxLines: 3,
                        decoration: InputDecoration(
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 32),
                            child: Icon(Icons.description_outlined),
                          ),
                          hintText: 'Deskripsi Detail',
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Tombol Simpan Laporan
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitReport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC87038),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Kirim Laporan',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // OVERLAY LOADING OVERLAY KETIKA _isLoading BERJALAN
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        CircularProgressIndicator(color: Color(0xFFC87038)),
                        SizedBox(height: 16),
                        Text(
                          'Menyimpan Laporan...',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3D2314),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFFC87038),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'Lapor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Laporan Saya',
          ),
        ],
      ),
    );
  }
}