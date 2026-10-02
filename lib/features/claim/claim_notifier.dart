import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'claim_repository.dart';
import 'claim_state.dart';

final claimRepositoryProvider = Provider<ClaimRepository>((ref) {
  return ClaimRepository();
});

final claimNotifierProvider =
    StateNotifierProvider.family<ClaimNotifier, ClaimState, String>(
        (ref, itemId) {
  final repository = ref.watch(claimRepositoryProvider);
  return ClaimNotifier(repository, itemId);
});

class ClaimNotifier extends StateNotifier<ClaimState> {
  final ClaimRepository _repository;
  final String itemId;

  ClaimNotifier(this._repository, this.itemId) : super(const ClaimState()) {
    loadItemDetails();
  }

  // Memuat detail barang
  Future<void> loadItemDetails() async {
    state = state.copyWith(status: ClaimStatus.loading, errorMessage: null);
    try {
      final data = await _repository.getItemDetails(itemId);
      if (data == null) {
        state = state.copyWith(status: ClaimStatus.empty);
      } else {
        state = state.copyWith(status: ClaimStatus.success, itemData: data);
      }
    } catch (e) {
      state = state.copyWith(
        status: ClaimStatus.error,
        errorMessage: 'Gagal memuat data barang: ${e.toString()}',
      );
    }
  }

  // Mengirim form klaim (Loading & Anti Double Tap)
  Future<bool> submitClaimForm({
    required String name,
    required String phone,
    required String reason,
  }) async {
    state = state.copyWith(isSubmitting: true);
    try {
      await _repository.submitClaim(
        itemId: itemId,
        claimantName: name,
        claimantPhone: phone,
        reason: reason,
      );
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Gagal mengajukan klaim: ${e.toString()}',
      );
      return false;
    }
  }
}