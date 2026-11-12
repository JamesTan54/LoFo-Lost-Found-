import 'package:flutter/material.dart';
import 'profile_repository.dart';
import 'profile_validation.dart';

class ProfileForm extends StatefulWidget {
  final ProfileRepository repository;

  const ProfileForm({super.key, required this.repository});

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  String? _statusMessage;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    final success = await widget.repository.updateProfile(
      name: _nameController.text,
      phone: _phoneController.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _statusMessage = success ? 'Profil berhasil disimpan!' : 'Gagal memperbarui profil.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nama Lengkap'),
            validator: ProfileValidation.validateName,
          ),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Nomor HP'),
            keyboardType: TextInputType.phone,
            validator: ProfileValidation.validatePhone,
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Simpan Profile'),
            ),
          if (_statusMessage != null) ...[
            const SizedBox(height: 12),
            Text(_statusMessage!),
          ],
        ],
      ),
    );
  }
}