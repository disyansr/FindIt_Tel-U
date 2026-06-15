import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  // SIGN UP
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _user = await _authService.signUp(
        name: name,
        email: email,
        password: password,
      );
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _errorMessage = _parseError(e.toString());
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // SIGN IN
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _user = await _authService.signIn(
        email: email,
        password: password,
      );
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _errorMessage = _parseError(e.toString());
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // SIGN OUT
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  String _parseError(String error) {
    if (error.contains('user-not-found')) return 'Email tidak terdaftar.';
    if (error.contains('wrong-password')) return 'Password salah.';
    if (error.contains('invalid-credential')) return 'Email atau password salah.';
    if (error.contains('email-already-in-use')) return 'Email sudah digunakan.';
    if (error.contains('weak-password')) return 'Password minimal 6 karakter.';
    if (error.contains('invalid-email')) return 'Format email tidak valid.';
    if (error.contains('network-request-failed')) return 'Tidak ada koneksi internet.';
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }
}