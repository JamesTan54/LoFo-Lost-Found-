import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemDetailScreen extends StatelessWidget {
  final Map itemData;

  const ItemDetailScreen({super.key, required this.itemData});

  // Fungsi untuk membuka WhatsApp
  Future _openWhatsApp(BuildContext context, String phone, String itemTitle) async {
    // Format nomor telepon menjadi standar internasional (62xxxx)
    String cleanedPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanedPhone.startsWith('0')) {
      cleanedPhone = '62${cleanedPhone.substring(1)}';
    }

    final String message = Uri.encodeComponent(
      'Halo, saya menghubungi Anda via aplikasi LoFo terkait laporan "$itemTitle".',
    );
    final Uri url = Uri.parse('https://wa.me/(cleanedPhone?text=)message');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak dapat membuka WhatsApp')),
          );
        }
      }
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
    final isLost = itemData['type'] == 'lost';
    final String? imageString = itemData['imageUrl'];
    final String? phone = itemData['contactPhone'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // BOX GAMBAR
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey[200],
              child: imageString != null && imageString.isNotEmpty
                  ? _buildImage(imageString)
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Tidak Ada Foto', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLost ? Colors.red[50] : Colors.green[50],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: isLost ? Colors.red : Colors.green),
                    ),
                    child: Text(
                      isLost ? 'BARANG HILANG' : 'BARANG DITEMUKAN',
                      style: TextStyle(
                        color: isLost ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    itemData['title'] ?? 'Tanpa Nama',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blue, size: 20),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          itemData['location'] ?? 'Lokasi tidak diketahui',
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  const Text(
                    'Deskripsi Laporan:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    itemData['description'] ?? 'Tidak ada deskripsi.',
                    style: const TextStyle(fontSize: 15, height: 1.4),
                  ),
                  const Divider(height: 32),

                  const Text(
                    'Kontak Pelapor:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.email, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        itemData['userEmail'] ?? 'Anonim',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  if (phone != null && phone.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.grey, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          phone,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  // --- TOMBOL HUBUNGI VIA WHATSAPP ---
                  if (phone != null && phone.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _openWhatsApp(context, phone, itemData['title'] ?? 'Barang'),
                        icon: const Icon(Icons.chat, color: Colors.white),
                        label: const Text(
                          'Hubungi Pelapor via WhatsApp',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366), // Warna WhatsApp Green
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imageStr) {
    if (imageStr.startsWith('http://') || imageStr.startsWith('https://')) {
      return Image.network(
        imageStr,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
        ),
      );
    }

    try {
      return Image.memory(
        base64Decode(imageStr),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
        ),
      );
    } catch (e) {
      return const Center(
        child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
      );
    }
  }
}