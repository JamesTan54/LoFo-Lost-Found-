import 'package:flutter_test/flutter_test.dart';
import 'package:lofo_lost_found/features/claim/profile/profile_validation.dart';

void main() {
  group('ProfileValidation Tests', () {
    test('Nama kosong harus return pesan error', () {
      final result = ProfileValidation.validateName('');
      expect(result, 'Nama tidak boleh kosong');
    });

    test('Nama valid harus return null', () {
      final result = ProfileValidation.validateName('James');
      expect(result, isNull);
    });

    test('Nomor HP kurang dari 10 digit harus return error', () {
      final result = ProfileValidation.validatePhone('08123');
      expect(result, 'Nomor HP harus berupa 10-13 digit angka');
    });
  });
}