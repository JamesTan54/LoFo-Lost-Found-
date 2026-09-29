
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State createState() => _HomeScreenState();
}

class _HomeScreenState extends State {
  static const Color primaryColor = Color(0xFFC87038);
  static const Color darkHeaderColor = Color(0xFF3D2314);

  int _currentIndex = 0;
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  // FUNGSI KHUSUS DETEKSI STATUS BARANG (HILANG / DITEMUKAN)
  bool _isItemHilang(Map data) {
    final statusFields = [
      data['status'],
      data['jenis'],
      data['jenisLaporan'],
      data['type'],
      data['tipe'],
      data['statusLaporan'],
      data['category'],
      data['kategori'],
      data['kategoriBarang'],
    ];

    // 1. Cek nilai persis di field Firestore
    for (var field in statusFields) {
      if (field != null) {
        final val = field.toString().trim().toLowerCase();
        if (val == 'ditemukan' || val == 'ketemu' || val == 'penemuan' || val == 'found') {
          return false;
        }
        if (val == 'hilang' || val == 'kehilangan' || val == 'lost') {
          return true;
        }
      }
    }

    // 2. Cek tipe boolean jika ada
    if (data['isHilang'] is bool) return data['isHilang'];
    if (data['isFound'] is bool) return !data['isFound'];

    // 3. Cek pencocokan substring
    for (var field in statusFields) {
      if (field != null) {
        final val = field.toString().trim().toLowerCase();
        if (val.contains('ditemukan') || val.contains('ketemu') || val.contains('penemuan') || val.contains('found')) {
          if (!val.contains('belum')) return false;
        }
        if (val.contains('hilang') || val.contains('kehilangan') || val.contains('lost')) {
          return true;
        }
      }
    }

    return true; // Default
  }

  // FUNGSI MEMBUKA MENU FILTER
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Kategori',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    children: ['Semua', 'Hilang', 'Ditemukan'].map((category) {
                      final isSelected = _selectedCategory == category;
                      return ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        selectedColor: primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                            setModalState(() {});
                            Navigator.pop(context);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // FUNGSI TAMPILKAN DETAIL LAPORAN
  void _showDetailModal({
    required String title,
    required String category,
    required String location,
    required String contact,
    required bool isHilang,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Chip(
                label: Text(
                  category,
                  style: TextStyle(
                    color: isHilang ? const Color(0xFFC62828) : const Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: isHilang ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
              ),
              const Divider(height: 24),
              ListTile(
                leading: const Icon(Icons.location_on, color: primaryColor),
                title: const Text('Lokasi'),
                subtitle: Text(location),
                contentPadding: EdgeInsets.zero,
              ),
              ListTile(
                leading: const Icon(Icons.phone, color: primaryColor),
                title: const Text('Kontak'),
                subtitle: Text(contact),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F5),
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ATAS ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: darkHeaderColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.search, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'LoFo',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        tooltip: 'Logout',
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                        },
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Search Bar & Filter Button
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value.toLowerCase();
                              });
                            },
                            decoration: const InputDecoration(
                              icon: Icon(Icons.search, color: Colors.grey),
                              hintText: 'Temukan Barangmu',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: _selectedCategory != 'Semua' ? const Color(0xFFFF8F00) : primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.tune, color: Colors.white),
                          tooltip: 'Filter Kategori',
                          onPressed: _showFilterBottomSheet,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (_selectedCategory != 'Semua')
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
                child: Row(
                  children: [
                    Text(
                      'Filter Aktif: $_selectedCategory',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = 'Semua';
                        });
                      },
                      child: const Text(
                        'Reset Filter',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // --- DAFTAR LAPORAN BARANG ---
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('items').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.inbox_outlined, size: 70, color: Color(0xFFBDBDBD)),
                          SizedBox(height: 12),
                          Text(
                            'Belum ada laporan barang.',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }

                  var docs = snapshot.data!.docs;

                  // PROSES FILTER KATEGORI
                  if (_selectedCategory == 'Hilang') {
                    docs = docs.where((doc) {
                      final data = doc.data() as Map;
                      return _isItemHilang(data);
                    }).toList();
                  } else if (_selectedCategory == 'Ditemukan') {
                    docs = docs.where((doc) {
                      final data = doc.data() as Map;
                      return !_isItemHilang(data);
                    }).toList();
                  }

                  // PROSES FILTER PENCARIAN
                  if (_searchQuery.isNotEmpty) {
                    docs = docs.where((doc) {
                      final data = doc.data() as Map;
                      final title = (data['title'] ?? data['namaBarang'] ?? data['nama'] ?? data['judul'] ?? '').toString().toLowerCase();
                      return title.contains(_searchQuery);
                    }).toList();
                  }

                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        'Tidak ada data untuk filter "$_selectedCategory"',
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map;
                      
                      final title = data['title'] ?? data['namaBarang'] ?? data['nama'] ?? data['judul'] ?? 'Tanpa Judul';
                      final location = data['location'] ?? data['lokasi'] ?? data['tempat'] ?? 'Tidak diketahui';
                      final contact = data['contact'] ?? data['kontak'] ?? data['phone'] ?? data['noHp'] ?? data['telepon'] ?? '-';
                      final imageUrl = data['imageUrl'] ?? data['image'] ?? data['foto'] ?? data['gambar'];

                      // Sinkronisasi status dan label badge
                      final isHilang = _isItemHilang(data);
                      final categoryLabel = isHilang ? 'Hilang' : 'Ditemukan';

                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          _showDetailModal(
                            title: title,
                            category: categoryLabel,
                            location: location,
                            contact: contact,
                            isHilang: isHilang,
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          color: const Color(0xFFFFF6F0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEEEEE),
                                    borderRadius: BorderRadius.circular(12),
                                    image: (imageUrl != null && imageUrl.toString().isNotEmpty)
                                        ? DecorationImage(
                                            image: NetworkImage(imageUrl),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: (imageUrl == null || imageUrl.toString().isEmpty)
                                      ? const Icon(Icons.image, color: Color(0xFFBDBDBD), size: 32)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Lokasi: $location',
                                        style: const TextStyle(color: Color(0xFF616161), fontSize: 13),
                                      ),
                                      Text(
                                        'Kontak: $contact',
                                        style: const TextStyle(color: Color(0xFF616161), fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isHilang ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    categoryLabel,
                                    style: TextStyle(
                                      color: isHilang ? const Color(0xFFD32F2F) : const Color(0xFF388E3C),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // --- BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) {
            Navigator.pushNamed(context, AppRoutes.addItem);
          }
        },
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