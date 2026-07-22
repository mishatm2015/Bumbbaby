import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> register({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> updateDisplayName(String name) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.updateDisplayName(name.trim());
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() => _auth.signOut();

  static String messageFor(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'weak-password':
          return 'Password must be at least 6 characters.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'network-request-failed':
          return 'Network error. Check your connection.';
        case 'operation-not-allowed':
          return 'Email/password sign-in is not enabled in Firebase Console.';
        case 'configuration-not-found':
        case 'internal-error':
          final details = error.message ?? '';
          if (details.contains('CONFIGURATION_NOT_FOUND')) {
            return 'Firebase Auth is not set up yet. In Firebase Console → Authentication, click Get started and enable Email/Password.';
          }
          return details.isNotEmpty ? details : 'Authentication failed.';
        default:
          final details = error.message ?? '';
          if (details.contains('CONFIGURATION_NOT_FOUND')) {
            return 'Firebase Auth is not set up yet. In Firebase Console → Authentication, click Get started and enable Email/Password.';
          }
          return details.isNotEmpty ? details : 'Authentication failed.';
      }
    }
    final text = error.toString();
    if (text.contains('CONFIGURATION_NOT_FOUND')) {
      return 'Firebase Auth is not set up yet. In Firebase Console → Authentication, click Get started and enable Email/Password.';
    }
    return text;
  }
}
