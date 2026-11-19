import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../routes/app_routes.dart';
import '../services/app_logger.dart';
import 'item_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const Color primaryColor = Color(0xFFC87038);
  static const Color darkHeaderColor = Color(0xFF3D2314);

  final int _currentIndex = 0;
  String _filterType = 'Semua';

  // CONTROLLER & STATE SEARCH BAR
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _cleanupTimer;

  @override
  void initState() {
    super.initState();
    _cleanupTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _cleanupTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    if (index == 1) {
      Navigator.pushReplacementNamed(context, AppRoutes.addItem);
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, AppRoutes.myReports);
    }
  }

  Future _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFAF7F5),
      appBar: AppBar(
        backgroundColor: darkHeaderColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'LoFo - Lost & Found',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Ganti Tema',
            icon: Icon(
              ref.watch(themeModeProvider) == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Keluar',
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // SEARCH BAR
            Container(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari barang atau lokasi...',
                  hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
                  prefixIcon: Icon(Icons.search, color: isDark ? Colors.grey[400] : Colors.grey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: isDark ? Colors.grey[400] : Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFFAF7F5),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: primaryColor),
                  ),
                ),
              ),
            ),

            // FILTER BAR
            Container(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  _buildFilterChip('Semua', isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('Hilang', isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('Ditemukan', isDark),
                ],
              ),
            ),
            Divider(height: 1, color: isDark ? Colors.grey.shade800 : null),

            // STREAM FIRESTORE (Disesuaikan ke koleksi 'reports')
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('reports')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 12),
                          Text(
                            'Terjadi kesalahan: ${snapshot.error}',
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => setState(() {}),
                            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                            child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];
                  final now = DateTime.now();

                  // PENYARINGAN (Mendukung Auto-Hapus 30 Menit, Jenis Laporan & Kata Kunci Search)
                  final filteredDocs = docs.where((doc) {
                    final data = doc.data() as Map? ?? {};
                    final rawType = (data['type'] ?? data['status'] ?? '').toString().toLowerCase();

                    // Auto-hapus jika status sudah Ditemukan lebih dari 30 menit
                    final isFoundStatus = rawType == 'found' || rawType == 'barang ditemukan' || rawType == 'ditemukan';
                    if (isFoundStatus && data['foundAt'] != null) {
                      final foundTime = (data['foundAt'] as Timestamp).toDate();
                      final elapsedMinutes = now.difference(foundTime).inMinutes;

                      if (elapsedMinutes >= 30) {
                        doc.reference.delete();
                        AppLogger.info('AUTO_CLEANUP', 'Laporan ${doc.id} dihapus otomatis (>30 menit)');
                        return false;
                      }
                    }

                    // 1. Filter Kategori (Hilang / Ditemukan)
                    bool matchesCategory = true;
                    if (_filterType == 'Hilang') {
                      matchesCategory = rawType == 'lost' || rawType == 'barang hilang';
                    } else if (_filterType == 'Ditemukan') {
                      matchesCategory = rawType == 'found' || rawType == 'barang ditemukan';
                    }

                    // 2. Filter Search Bar (Berdasarkan Judul & Lokasi)
                    final title = (data['title'] ?? '').toString().toLowerCase();
                    final location = (data['location'] ?? '').toString().toLowerCase();
                    bool matchesSearch = title.contains(_searchQuery) || location.contains(_searchQuery);

                    return matchesCategory && matchesSearch;
                  }).toList();

                  // PENGURUTAN (Laporan baru/timestamp null ditaruh di Paling Atas)
                  filteredDocs.sort((a, b) {
                    final dataA = a.data() as Map? ?? {};
                    final dataB = b.data() as Map? ?? {};
                    final timeA = dataA['createdAt'] as Timestamp?;
                    final timeB = dataB['createdAt'] as Timestamp?;

                    if (timeA == null && timeB == null) return 0;
                    if (timeA == null) return -1;
                    if (timeB == null) return 1;
                    return timeB.compareTo(timeA);
                  });

                  if (filteredDocs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 64, color: isDark ? Colors.grey[400] : Colors.grey),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada laporan barang',
                            style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[300] : Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final itemDoc = filteredDocs[index];
                      final itemData = itemDoc.data() as Map? ?? {};

                      final String title = (itemData['title'] ?? 'Tanpa Judul').toString();
                      final String location = (itemData['location'] ?? '-').toString();
                      final String imageUrl = (itemData['imageUrl'] ?? '').toString();

                      // KONVERSI TAMPILAN STATUS
                      final String rawType = (itemData['type'] ?? itemData['status'] ?? 'lost').toString().toLowerCase();
                      final bool isLost = rawType == 'lost' || rawType == 'barang hilang';
                      final String displayStatus = isLost ? 'Hilang' : 'Ditemukan';

                      return Card(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ItemDetailScreen(
                                  itemData: Map<String, dynamic>.from(itemData)..['id'] = itemDoc.id,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: imageUrl.trim().isNotEmpty
                                      ? Image.network(
                                          imageUrl,
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(isDark),
                                        )
                                      : _buildPlaceholderImage(isDark),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: isDark ? Colors.white : darkHeaderColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on, size: 14, color: isDark ? Colors.grey[400] : Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              location,
                                              style: TextStyle(
                                                color: isDark ? Colors.grey[300] : Colors.grey,
                                                fontSize: 13,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isLost ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isLost ? Colors.red : Colors.green,
                                    ),
                                  ),
                                  child: Text(
                                    displayStatus,
                                    style: TextStyle(
                                      color: isLost ? Colors.red[800] : Colors.green[800],
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        currentIndex: _currentIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey,
        onTap: _onTabTapped,
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

  Widget _buildFilterChip(String label, bool isDark) {
    final bool isSelected = _filterType == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: primaryColor,
      backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[200],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _filterType = label;
          });
        }
      },
    );
  }

  Widget _buildPlaceholderImage(bool isDark) {
    return Container(
      width: 70,
      height: 70,
      color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[200],
      child: Icon(Icons.image_not_supported, color: isDark ? Colors.grey[400] : Colors.grey, size: 30),
    );
  }
}