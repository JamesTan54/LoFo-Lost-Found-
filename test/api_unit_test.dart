import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../lib/models/api_item_model.dart';
import '../lib/services/api_service.dart';
import 'api_unit_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockClient;
  late ApiService apiService;

  setUp(() {
    mockClient = MockClient();
    apiService = ApiService(client: mockClient);
  });

  group('Tugas P6 - 6 Unit Tests Integrasi API', () {
    // 1. Model Valid
    test('1. Model Valid - Berhasil parsing JSON yang valid', () {
      final jsonMap = {
        'id': '101',
        'title': 'Dompet Cokelat',
        'category': 'Aksesori',
      };
      final model = ApiItemModel.fromJson(jsonMap);

      expect(model.id, '101');
      expect(model.title, 'Dompet Cokelat');
    });

    // 2. Model Invalid
    test('2. Model Invalid - Melempar FormatException jika field utama hilang', () {
      final invalidJson = {'category': 'Aksesori'}; // Tanpa 'id' dan 'title'

      expect(
        () => ApiItemModel.fromJson(invalidJson),
        throwsA(isA<FormatException>()),
      );
    });

    // 3. API Sukses
    test('3. API Sukses - Mengembalikan list barang saat response 200 OK', () async {
      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response('[{"id": "1", "title": "Laptop HP"}]', 200),
      );

      final result = await apiService.fetchItems();

      expect(result, isA<List<ApiItemModel>>());
      expect(result.length, 1);
      expect(result.first.title, 'Laptop HP');
    });

    // 4. Data Kosong
    test('4. Data Kosong - Mengembalikan list kosong saat response []', () async {
      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response('[]', 200),
      );

      final result = await apiService.fetchItems();

      expect(result, isEmpty);
    });

    // 5. HTTP Gagal
    test('5. HTTP Gagal - Melempar Exception saat status code 404/500', () async {
      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response('Not Found', 404),
      );

      expect(apiService.fetchItems(), throwsException);
    });

    // 6. JSON Rusak
    test('6. JSON Rusak - Melempar FormatException saat format JSON tidak valid', () async {
      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response('{invalid_json_format', 200),
      );

      expect(apiService.fetchItems(), throwsA(isA<FormatException>()));
    });
  });
}