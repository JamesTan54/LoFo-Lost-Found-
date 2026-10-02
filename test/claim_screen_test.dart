import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lofo_lost_found/features/claim/claim_repository.dart';
import 'package:lofo_lost_found/features/claim/claim_screen.dart';
import 'package:lofo_lost_found/features/claim/claim_notifier.dart';


class FakeClaimRepository extends ClaimRepository {
  final Map<String, dynamic>? mockData;
  final bool shouldThrowError;

  FakeClaimRepository({this.mockData, this.shouldThrowError = false});

  @override
  Future<Map<String, dynamic>?> getItemDetails(String itemId) async {
    if (shouldThrowError) {
      throw Exception('Gagal terkoneksi ke server');
    }
    return mockData;
  }

  @override
  Future<void> submitClaim({
    required String itemId,
    required String claimantName,
    required String claimantPhone,
    required String reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}

void main() {
  testWidgets('1. Test Initial Loading State', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          claimRepositoryProvider.overrideWithValue(FakeClaimRepository()),
        ],
        child: const MaterialApp(home: ClaimScreen(itemId: '123')),
      ),
    );

    expect(find.byKey(const Key('loading_indicator')), findsOneWidget);
  });

  testWidgets('2. Test Data Berhasil Dimuat (Success)', (WidgetTester tester) async {
    final fakeRepo = FakeClaimRepository(
      mockData: {'title': 'Kunci Motor Honda', 'location': 'Parkiran Gedung B'},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [claimRepositoryProvider.overrideWithValue(fakeRepo)],
        child: const MaterialApp(home: ClaimScreen(itemId: '123')),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Kunci Motor Honda'), findsOneWidget);
    expect(find.text('Lokasi: Parkiran Gedung B'), findsOneWidget);
  });

  testWidgets('3. Test Empty State', (WidgetTester tester) async {
    final fakeRepo = FakeClaimRepository(mockData: null);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [claimRepositoryProvider.overrideWithValue(fakeRepo)],
        child: const MaterialApp(home: ClaimScreen(itemId: '123')),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('empty_state_text')), findsOneWidget);
  });

  testWidgets('4. Test Error State & Tombol Retry', (WidgetTester tester) async {
    final fakeRepo = FakeClaimRepository(shouldThrowError: true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [claimRepositoryProvider.overrideWithValue(fakeRepo)],
        child: const MaterialApp(home: ClaimScreen(itemId: '123')),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('retry_button')), findsOneWidget);
  });

  testWidgets('5. Test Validasi Input Form', (WidgetTester tester) async {
    final fakeRepo = FakeClaimRepository(
      mockData: {'title': 'Dompet', 'location': 'Kantin'},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [claimRepositoryProvider.overrideWithValue(fakeRepo)],
        child: const MaterialApp(home: ClaimScreen(itemId: '123')),
      ),
    );

    await tester.pumpAndSettle();

    // Tekan tombol simpan tanpa isi input
    await tester.tap(find.byKey(const Key('submit_button')));
    await tester.pump();

    expect(find.text('Nama lengkap wajib diisi'), findsOneWidget);
    expect(find.text('Nomor WhatsApp wajib diisi'), findsOneWidget);
  });
}