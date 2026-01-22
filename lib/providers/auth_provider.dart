import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'screening_history_provider.dart' as history;

// Model untuk User
class User {
  final String id;
  final String name;
  final String email;
  final String? profileImage;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'profileImage': profileImage,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    profileImage: json['profileImage'],
  );
}

// State untuk Auth
class AuthState {
  final bool isLoggedIn;
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.isLoggedIn = false,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// StateNotifier untuk mengelola Auth
class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(AuthState()) {
    _initFromFirebase();
  }

  void _initFromFirebase() {
    final fbUser = fb.FirebaseAuth.instance.currentUser;
    if (fbUser != null) {
      final user = User(
        id: fbUser.uid,
        name: fbUser.displayName ?? (fbUser.email?.split('@').first.toUpperCase() ?? ''),
        email: fbUser.email ?? '',
        profileImage: fbUser.photoURL,
      );

      state = state.copyWith(
        isLoggedIn: true,
        user: user,
      );

      // Jika user sudah login saat app dibuka ulang,
      // langsung muat riwayat screening dari Firestore.
      ref.read(history.screeningHistoryProvider.notifier).loadFromFirestore();
    }
  }

  // Login function
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Validasi sederhana
      if (email.isEmpty || password.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'Email dan password tidak boleh kosong',
        );
        return false;
      }

      if (!email.contains('@')) {
        state = state.copyWith(
          isLoading: false,
          error: 'Email tidak valid',
        );
        return false;
      }

      if (password.length < 6) {
        state = state.copyWith(
          isLoading: false,
          error: 'Password minimal 6 karakter',
        );
        return false;
      }

      // Firebase Auth sign in
      try {
        final credential = await fb.FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        final fbUser = credential.user;
        if (fbUser == null) {
          state = state.copyWith(
            isLoading: false,
            error: 'Gagal login, silakan coba lagi',
          );
          return false;
        }

        final user = User(
          id: fbUser.uid,
          name: fbUser.displayName ?? email.split('@')[0].toUpperCase(),
          email: fbUser.email ?? email,
          profileImage: fbUser.photoURL,
        );

        state = state.copyWith(
          isLoggedIn: true,
          user: user,
          isLoading: false,
          error: null,
        );

        return true;
      } on fb.FirebaseAuthException catch (e) {
        String message = 'Terjadi kesalahan, silakan coba lagi';
        if (e.code == 'user-not-found') {
          message = 'Email tidak terdaftar';
        } else if (e.code == 'wrong-password') {
          message = 'Password salah';
        } else if (e.code == 'invalid-email') {
          message = 'Format email tidak valid';
        } else if (e.code == 'user-disabled') {
          message = 'Akun ini telah dinonaktifkan';
        }

        state = state.copyWith(
          isLoading: false,
          error: message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Terjadi kesalahan: ${e.toString()}',
      );
      return false;
    }
  }

  // Register function
  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Validasi
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'Semua field harus diisi',
        );
        return false;
      }

      if (!email.contains('@')) {
        state = state.copyWith(
          isLoading: false,
          error: 'Email tidak valid',
        );
        return false;
      }

      if (password.length < 6) {
        state = state.copyWith(
          isLoading: false,
          error: 'Password minimal 6 karakter',
        );
        return false;
      }

      // Firebase Auth register
      try {
        final credential = await fb.FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        final fbUser = credential.user;
        if (fbUser == null) {
          state = state.copyWith(
            isLoading: false,
            error: 'Gagal registrasi, silakan coba lagi',
          );
          return false;
        }

        await fbUser.updateDisplayName(name);

        // Jangan auto-login setelah registrasi. Paksa user login manual.
        await fb.FirebaseAuth.instance.signOut();
        state = AuthState(isLoggedIn: false, user: null, isLoading: false, error: null);
        return true;
      } on fb.FirebaseAuthException catch (e) {
        String message = 'Terjadi kesalahan, silakan coba lagi';
        if (e.code == 'email-already-in-use') {
          message = 'Email sudah digunakan';
        } else if (e.code == 'weak-password') {
          message = 'Password terlalu lemah';
        } else if (e.code == 'invalid-email') {
          message = 'Format email tidak valid';
        }

        state = state.copyWith(
          isLoading: false,
          error: message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Terjadi kesalahan: ${e.toString()}',
      );
      return false;
    }
  }

  // Google Sign-In
  Future<bool> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        state = state.copyWith(isLoading: false, error: 'Login dibatalkan');
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await fb.FirebaseAuth.instance.signInWithCredential(credential);
      final fbUser = userCredential.user;

      if (fbUser == null) {
        state = state.copyWith(isLoading: false, error: 'Login Google gagal');
        return false;
      }

      final user = User(
        id: fbUser.uid,
        name: fbUser.displayName ?? (fbUser.email?.split('@').first.toUpperCase() ?? ''),
        email: fbUser.email ?? googleUser.email,
        profileImage: fbUser.photoURL,
      );

      state = state.copyWith(
        isLoggedIn: true,
        user: user,
        isLoading: false,
        error: null,
      );

      // Muat riwayat screening setelah login
      await ref.read(history.screeningHistoryProvider.notifier).loadFromFirestore();

      return true;
    } on fb.FirebaseAuthException catch (e) {
      String message = 'Login Google gagal';
      if (e.code == 'account-exists-with-different-credential') {
        message = 'Email sudah terdaftar dengan metode lain.';
      }
      state = state.copyWith(isLoading: false, error: message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Terjadi kesalahan: ${e.toString()}',
      );
      return false;
    }
  }

  // Logout function
  void logout() {
    fb.FirebaseAuth.instance.signOut();
    state = AuthState();
  }

  // Update user function
  void updateUser(User updatedUser) {
    state = state.copyWith(
      user: updatedUser,
    );
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
