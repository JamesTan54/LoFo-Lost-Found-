import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'claim_notifier.dart';
import 'claim_state.dart';

class ClaimScreen extends ConsumerStatefulWidget {
  final String itemId;

  const ClaimScreen({super.key, required this.itemId});

  @override
  ConsumerState<ClaimScreen> createState() => _ClaimScreenState();
}

class _ClaimScreenState extends ConsumerState<ClaimScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _reasonController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final claimState = ref.watch(claimNotifierProvider(widget.itemId));
    final notifier = ref.read(claimNotifierProvider(widget.itemId).notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F5),
      appBar: AppBar(
        title: const Text('Proses Booking Klaim'),
        backgroundColor: const Color(0xFF3D2314),
        foregroundColor: Colors.white,
      ),
      body: _buildBody(claimState, notifier),
    );
  }

  Widget _buildBody(ClaimState state, ClaimNotifier notifier) {
    // 1. Initial & Loading State
    if (state.status == ClaimStatus.loading || state.status == ClaimStatus.initial) {
      return const Center(
        child: CircularProgressIndicator(
          key: Key('loading_indicator'),
          color: Color(0xFFC87038),
        ),
      );
    }

    // 2. Error State dengan Tombol Retry
    if (state.status == ClaimStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                state.errorMessage ?? 'Terjadi kesalahan sistem',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                key: const Key('retry_button'),
                onPressed: () => notifier.loadItemDetails(),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC87038),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Empty State
    if (state.status == ClaimStatus.empty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 60, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Barang tidak ditemukan atau sudah diklaim.',
              key: Key('empty_state_text'),
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ],
        ),
      );
    }

    // 4. Data Berhasil Dimuat (Success), Form Validasi & Loading Submit
    final item = state.itemData ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kartu Ringkasan Barang
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.inventory_2, color: Color(0xFFC87038), size: 32),
                title: Text(
                  item['title'] ?? 'Barang Tanpa Nama',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Lokasi: ${item['location'] ?? '-'}'),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Isi Form Booking Klaim',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3D2314)),
            ),
            const SizedBox(height: 12),

            // 5. Validasi Input (Nama)
            TextFormField(
              key: const Key('name_field'),
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap Anda',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person, color: Color(0xFFC87038)),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Nama lengkap wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // 5. Validasi Input (Nomor Telepon)
            TextFormField(
              key: const Key('phone_field'),
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Nomor WhatsApp / HP',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone, color: Color(0xFFC87038)),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Nomor WhatsApp wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // 5. Validasi Input (Alasan / Bukti Kepemilikan)
            TextFormField(
              key: const Key('reason_field'),
              controller: _reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Alasan & Bukti Kepemilikan',
                hintText: 'Sebutkan ciri-ciri khusus barang Anda',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Bukti kepemilikan wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // 6. Loading saat Submit (Mencegah Double Tap)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                key: const Key('submit_button'),
                onPressed: state.isSubmitting
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          final success = await notifier.submitClaimForm(
                            name: _nameController.text.trim(),
                            phone: _phoneController.text.trim(),
                            reason: _reasonController.text.trim(),
                          );
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Klaim berhasil diajukan!')),
                            );
                            Navigator.pop(context);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC87038),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: state.isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'KIRIM PROSES KLAIM',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}