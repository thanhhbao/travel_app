// lib/services/auth_service.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Gọi 1 lần ở `main()` sau khi `Firebase.initializeApp(...)`
  Future<void> init() async {
    // Có thể truyền clientId/serverClientId nếu bạn muốn – không bắt buộc trên mobile.
    await GoogleSignIn.instance.initialize();
  }

  // Streams & state
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null;

  bool get isEmailLinked =>
      _auth.currentUser?.providerData.any((p) => p.providerId == 'password') ??
      false;

  bool get isGoogleLinked =>
      _auth.currentUser?.providerData.any(
        (p) => p.providerId == 'google.com',
      ) ??
      false;

  // ================= EMAIL / PASSWORD =================

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  // ================ GOOGLE (mobile/desktop) ================

  /// Đăng nhập Google -> Firebase.
  /// Web: ném UnsupportedError (hãy dùng nút GIS trên web).
  Future<UserCredential?> signInWithGoogle() async {
    // Web phải render button GIS (plugin v7); authenticate() không hỗ trợ.
    if (kIsWeb || !(await GoogleSignIn.instance.supportsAuthenticate())) {
      throw UnsupportedError(
        'GoogleSignIn.authenticate() không hỗ trợ trên Web. '
        'Hãy dùng nút Google Identity Services để đăng nhập Web.',
      );
    }

    final GoogleSignInAccount? account = await GoogleSignIn.instance
        .authenticate();
    if (account == null) return null; // user hủy

    // V7: authentication là getter đồng bộ; không dùng `await`.
    final GoogleSignInAuthentication tokens = account.authentication;

    if (tokens.idToken == null) {
      // Trường hợp hiếm, nhưng ta guard cho chắc.
      throw StateError('Không nhận được idToken từ Google.');
    }

    final credential = GoogleAuthProvider.credential(
      idToken: tokens.idToken,
      // accessToken có thể không còn trên một số nền tảng ở v7 -> bỏ trống cũng OK
    );

    return _auth.signInWithCredential(credential);
  }

  /// Link Google vào tài khoản đang đăng nhập (email/password -> +google).
  Future<UserCredential?> linkGoogleToCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Chưa đăng nhập.');

    if (kIsWeb || !(await GoogleSignIn.instance.supportsAuthenticate())) {
      throw UnsupportedError(
        'Link Google trên Web cần dùng nút GIS. '
        'Phương thức này chỉ dùng cho iOS/Android/macOS.',
      );
    }

    final GoogleSignInAccount? account = await GoogleSignIn.instance
        .authenticate();
    if (account == null) return null;

    final GoogleSignInAuthentication tokens = account.authentication;
    if (tokens.idToken == null) {
      throw StateError('Không nhận được idToken từ Google.');
    }

    final credential = GoogleAuthProvider.credential(idToken: tokens.idToken);
    return user.linkWithCredential(credential);
  }

  /// Link email/password vào tài khoản đang đăng nhập (google -> +email).
  Future<UserCredential> linkEmailPasswordToCurrentUser({
    required String email,
    required String password,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Chưa đăng nhập.');

    final cred = EmailAuthProvider.credential(email: email, password: password);
    return user.linkWithCredential(cred);
  }

  /// Unlink theo providerId: 'google.com' | 'password' | ...
  Future<void> unlinkProvider(String providerId) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Chưa đăng nhập.');
    await user.unlink(providerId);
  }

  // ===================== SIGN OUT =====================

  Future<void> signOut() async {
    await _auth.signOut();
    // Ngắt session Google (nếu có). Không lỗi nếu chưa đăng nhập Google.
    try {
      await GoogleSignIn.instance.disconnect();
    } catch (_) {}
  }
}
