enum ClaimStatus { initial, loading, success, empty, error }

class ClaimState {
  final ClaimStatus status;
  final Map<String, dynamic>? itemData;
  final String? errorMessage;
  final bool isSubmitting;

  const ClaimState({
    this.status = ClaimStatus.initial,
    this.itemData,
    this.errorMessage,
    this.isSubmitting = false,
  });

  ClaimState copyWith({
    ClaimStatus? status,
    Map<String, dynamic>? itemData,
    String? errorMessage,
    bool? isSubmitting,
  }) {
    return ClaimState(
      status: status ?? this.status,
      itemData: itemData ?? this.itemData,
      errorMessage: errorMessage ?? this.errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}