import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Getter user saat ini
  User? get currentUser => _auth.currentUser;

  // Stream perubahan status autentikasi
  Stream get authStateChanges => _auth.authStateChanges();

  // 1. Login dengan Email & Password
  Future signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // 2. Register / Daftar Akun Baru
  Future register({
    required String email,
    required String password,
    String? name,
  }) async {
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Simpan nama pengguna ke profil Firebase jika ada
    if (name != null && name.isNotEmpty) {
      await credential.user?.updateDisplayName(name);
    }

    return credential;
  }

  // 3. Login dengan Google (Web & Mobile)
  Future signInWithGoogle() async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        return await _auth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      rethrow;
    }
  }

  // 4. Logout / Keluar (Fungsi Sign Out)
  Future signOut() async {
    try {
      if (!kIsWeb) {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.signOut();
        }
      }
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}