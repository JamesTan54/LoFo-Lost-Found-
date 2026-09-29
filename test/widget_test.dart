import 'package:flutter_test/flutter_test.dart';
import 'package:lofo_lost_found/app.dart';

void main() {
  test('Pemeriksaan Inisialisasi MyApp', () {
    const app = MyApp();
    expect(app, isNotNull);
  });
}