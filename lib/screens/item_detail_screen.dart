import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/app_logger.dart';

class ItemDetailScreen extends StatelessWidget {
  final Map<String, dynamic> itemData;

  const ItemDetailScreen({super.key, required this.itemData});

  static const Color darkHeaderColor = Color(0xFF3D2314);
  static const Color primaryColor = Color(0xFFC87038);
  static const Color whatsappColor = Color(0xFF25D366);

  String _extractPhoneNumber(Map<String, dynamic> data) {
    final possibleKeys = [
      'contactPhone',
      'contact_phone',
      'phone',
      'phoneNumber',
      'phone_number',
      'whatsapp',
      'noHp',
    ];

    for (var key in possibleKeys) {
      if (data.containsKey(key) && data[key] != null) {
        final val = data[key].toString().trim();
        if (val.isNotEmpty) {
          return val;
        }
      }
    }
    return '';
  }

  Future<void> _openWhatsApp(BuildContext context, String rawPhone, String title) async {
    if (rawPhone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor telepon tidak tersedia')),
      );
      return;
    }

    String formattedPhone = rawPhone.replaceAll(RegExp(r'\D'), '');
    if (formattedPhone.startsWith('0')) {
      formattedPhone = '62${formattedPhone.substring(1)}';
    }

    final String message = Uri.encodeComponent(
      'Halo, saya menghubungi Anda terkait laporan "$title" di aplikasi LoFo.',
    );

    final Uri waUrl = Uri.parse('https://wa.me/$formattedPhone?text=$message');

    try {
      await launchUrl(waUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka WhatsApp: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String itemId = (itemData['id'] ?? itemData['docId'] ?? '').toString();
    final String title = (itemData['title'] ?? 'Tanpa Judul').toString();
    final String location = (itemData['location'] ?? '-').toString();
    final String description = (itemData['description'] ?? '-').toString();
    final String imageUrl = (itemData['imageUrl'] ?? '').toString();
    final String phone = _extractPhoneNumber(itemData);

    final String rawType = (itemData['type'] ?? itemData['status'] ?? 'lost').toString().toLowerCase();
    final bool isLost = rawType == 'lost' || rawType == 'hilang' || rawType == 'barang hilang';
    final String displayStatus = isLost ? 'Hilang' : 'Ditemukan';

    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final bool isOwner = currentUserId != null && currentUserId == (itemData['userId'] ?? '').toString();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFAF7F5),
      appBar: AppBar(
        backgroundColor: darkHeaderColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Detail Laporan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Barang
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: imageUrl.trim().isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(isDark),
                      ),
                    )
                  : _buildPlaceholderImage(isDark),
            ),
            const SizedBox(height: 16),

            // Judul & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : darkHeaderColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isLost ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isLost ? Colors.red : Colors.green),
                  ),
                  child: Text(
                    displayStatus,
                    style: TextStyle(
                      color: isLost ? Colors.red[800] : Colors.green[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: isDark ? Colors.grey.shade800 : null),

            // Lokasi
            Row(
              children: [
                const Icon(Icons.location_on, color: primaryColor, size: 22),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lokasi', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey, fontSize: 12)),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Telepon & WhatsApp Button
            Row(
              children: [
                const Icon(Icons.phone, color: primaryColor, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nomor WhatsApp', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey, fontSize: 12)),
                      Text(
                        phone.isNotEmpty ? phone : 'Tidak ada nomor',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: phone.isNotEmpty
                              ? (isDark ? Colors.white : Colors.black87)
                              : Colors.red[400],
                        ),
                      ),
                    ],
                  ),
                ),
                if (phone.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () => _openWhatsApp(context, phone, title),
                    icon: const Icon(Icons.chat, color: Colors.white, size: 18),
                    label: const Text('WhatsApp', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: whatsappColor),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: isDark ? Colors.grey.shade800 : null),

            // Deskripsi
            Text(
              'Deskripsi Detail',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : darkHeaderColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: isDark ? Colors.grey[200] : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // TOMBOL KHUSUS PEMBUAT LAPORAN: TANDAI DITEMUKAN
            if (isOwner && isLost)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (itemId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ID laporan tidak ditemukan')),
                      );
                      return;
                    }

                    await FirebaseFirestore.instance
                        .collection('reports')
                        .doc(itemId)
                        .update({
                      'type': 'Barang Ditemukan',
                      'foundAt': FieldValue.serverTimestamp(),
                    });

                    AppLogger.info('REPORT', 'Laporan $itemId ditandai Ditemukan');

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Status diubah menjadi Ditemukan. Laporan otomatis hilang dalam 30 menit.',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: const Text(
                    'TANDAI SUDAH DITEMUKAN',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_not_supported, size: 50, color: isDark ? Colors.grey[400] : Colors.grey),
        const SizedBox(height: 8),
        Text('Tidak Ada Gambar', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey)),
      ],
    );
  }
}