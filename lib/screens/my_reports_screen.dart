import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    const primaryBrown = Color(0xFFC87038);
    const darkBrown = Color(0xFF3D2115);
    final isWebDesktop = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: isWebDesktop ? const Color(0xFFF4F0EC) : Colors.white,
      appBar: AppBar(
        title: const Text('Laporanku', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: darkBrown,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Container(
            color: Colors.white,
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('items')
                  .where('userId', isEqualTo: user?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: primaryBrown));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Kamu belum pernah membuat laporan.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map;
                    final docId = docs[index].id;
                    final title = data['title'] ?? 'Tanpa Judul';
                    final isLost = (data['type'] ?? '') == 'Hilang';

                    return Card(
                      elevation: 0,
                      color: const Color(0xFFFAF8F5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isLost ? Colors.red.shade100 : Colors.orange.shade100,
                          child: Icon(
                            isLost ? Icons.search_off : Icons.check,
                            color: isLost ? Colors.red : primaryBrown,
                          ),
                        ),
                        title: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Status: ${isLost ? "Barang Hilang" : "Barang Ditemukan"}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('items')
                                .doc(docId)
                                .delete();
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}