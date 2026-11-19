import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../routes/app_routes.dart';
import '../services/app_logger.dart';
import 'item_detail_screen.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State {
  final int _currentIndex = 2;
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
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;

    if (index == 0) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, AppRoutes.addItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFAF7F5),
      appBar: AppBar(
        title: const Text('Laporan Saya'),
        backgroundColor: const Color(0xFF3D2314),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: user == null
          ? Center(
              child: Text(
                'Silakan login terlebih dahulu.',
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
            )
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('reports')
                  .where('userId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFC87038)),
                  );
                }

                final now = DateTime.now();
                final docs = (snapshot.data?.docs ?? []).where((doc) {
                  final data = doc.data() as Map? ?? {};
                  final rawType = (data['type'] ?? data['status'] ?? '').toString().toLowerCase();
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
                  return true;
                }).toList();

                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      'Belum ada laporan yang dibuat.',
                      style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black87),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final rawData = doc.data() as Map? ?? {};

                    final itemData = {
                      'id': doc.id,
                      ...rawData,
                    };

                    return Card(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(
                          itemData['title'] ?? 'Tanpa Judul',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          itemData['description'] ?? '-',
                          style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700]),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: isDark ? Colors.grey[400] : Colors.grey,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ItemDetailScreen(
                                itemData: Map<String, dynamic>.from(itemData),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFFC87038),
        unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey,
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