class ProfileRepository {
  Future<bool> updateProfile({required String name, required String phone}) async {
    try {
      // Logika request API / Firestore
      await Future.delayed(const Duration(seconds: 1)); // Simulasi network
      return true;
    } catch (e) {
      return false;
    }
  }
}