import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user.dart';
import 'api_service.dart';

/// Manages JWT persistence using [FlutterSecureStorage] and exposes
/// reactive authentication state to the widget tree via [ChangeNotifier].
class AuthService extends ChangeNotifier {
  static const String _tokenStorageKey = 'jansamasya_auth_token';
  static const String _userStorageKey = 'jansamasya_user_cache';

  final FlutterSecureStorage _secureStorage;
  final ApiService _apiService;

  String? _token;
  User? _user;
  bool _isLoading = false;

  AuthService({FlutterSecureStorage? secureStorage, ApiService? apiService})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
      _apiService = apiService ?? ApiService();

  String? get token => _token;
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  ApiService get apiService => _apiService;

  /// Restores any stored JWT on app startup and validates it against
  /// `GET /api/user/profile` when reachable.
  ///
  /// Returns `true` if a valid citizen session is active, `false` otherwise.
  Future<bool> initializeSession() async {
    try {
      final storedToken = await _secureStorage.read(key: _tokenStorageKey);
      if (storedToken == null || storedToken.isEmpty) {
        _token = null;
        _user = null;
        notifyListeners();
        return false;
      }

      _token = storedToken;

      // Load cached user details first in case the network is momentarily slow.
      final cachedUserJson = await _secureStorage.read(key: _userStorageKey);
      if (cachedUserJson != null && cachedUserJson.isNotEmpty) {
        try {
          final decoded = jsonDecode(cachedUserJson);
          if (decoded is Map<String, dynamic>) {
            _user = User.fromJson(decoded);
          }
        } on FormatException {
          // Ignore malformed cached user data.
        }
      }

      // Validate the token with the backend profile endpoint.
      try {
        final freshUser = await _apiService.getProfile(storedToken);
        _user = freshUser;
        await _secureStorage.write(
          key: _userStorageKey,
          value: jsonEncode(freshUser.toJson()),
        );
        notifyListeners();
        return true;
      } on UnauthorizedException {
        // Token is expired or invalid; clear stored credentials immediately.
        await logout();
        return false;
      } on ApiException {
        // If backend is temporarily unreachable, keep the cached session
        // only when cached user details exist; otherwise ask user to log in.
        notifyListeners();
        return _user != null;
      }
    } catch (_) {
      await logout();
      return false;
    }
  }

  /// Authenticates a citizen and stores the returned JWT securely.
  Future<void> login({
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final result = await _apiService.login(
        username: username,
        password: password,
      );
      _token = result.token;
      _user = result.user;

      await _secureStorage.write(key: _tokenStorageKey, value: result.token);
      await _secureStorage.write(
        key: _userStorageKey,
        value: jsonEncode(result.user.toJson()),
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Registers a new citizen account with the existing signup endpoint.
  Future<void> signup({
    required String username,
    required String email,
    required String password,
    required String state,
    String? area,
  }) async {
    _setLoading(true);
    try {
      await _apiService.signup(
        username: username,
        email: email,
        password: password,
        state: state,
        area: area,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Fetches fresh profile information from `GET /api/user/profile`.
  /// Automatically logs out if the token is expired (`UnauthorizedException`).
  Future<User> fetchProfile() async {
    final currentToken = _token;
    if (currentToken == null || currentToken.isEmpty) {
      throw const UnauthorizedException('You are not logged in.');
    }

    try {
      final freshUser = await _apiService.getProfile(currentToken);
      _user = freshUser;
      await _secureStorage.write(
        key: _userStorageKey,
        value: jsonEncode(freshUser.toJson()),
      );
      notifyListeners();
      return freshUser;
    } on UnauthorizedException {
      await logout();
      rethrow;
    }
  }

  /// Clears stored tokens and resets authentication state.
  Future<void> logout() async {
    _token = null;
    _user = null;
    try {
      await _secureStorage.delete(key: _tokenStorageKey);
      await _secureStorage.delete(key: _userStorageKey);
    } catch (_) {
      // Ensure in-memory state is always cleared even if storage fails.
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
