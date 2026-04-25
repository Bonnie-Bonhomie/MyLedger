import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_ledger/Models/user_model.dart';
import 'package:my_ledger/utils/constants/app_constant.dart';

enum AuthState { unauthenticated, faceVerification, authenticated }

class AuthProvider extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthState _authState = AuthState.unauthenticated;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthState get authState => _authState;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _authState == AuthState.authenticated;

  Future<void> init() async {
    final userId = await _secureStorage.read(key: 'current_user_id');
    if (userId != null) {
      final userBox = Hive.box<UserModel>(AppConstants.userBoxName);
      final user = userBox.values.firstWhere(
        (u) => u.id == userId,
        orElse: () => throw Exception('User not found'),
      );
      _currentUser = user;
      // Require face re-verification on app launch
      _authState = AuthState.faceVerification;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userBox = Hive.box<UserModel>(AppConstants.userBoxName);
      final exists = userBox.values.any((u) => u.email == email);
      if (exists) {
        _error = 'An account with this email already exists.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final user = UserModel(name: name, email: email);
      await userBox.put(user.id, user);
      await _secureStorage.write(key: 'pwd_${user.id}', value: password);
      _currentUser = user;
      return true;
    } catch (e) {
      _error = 'Registration failed. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userBox = Hive.box<UserModel>(AppConstants.userBoxName);
      final userList = userBox.values.where((u) => u.email == email).toList();
      print(userList);
      if (userList.isEmpty) {
        _error = 'No account found with this email.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final user = userList.first;

      final storedPass = await _secureStorage.read(key: 'pwd_${user.id}');
      print(storedPass);
      if (storedPass != password) {

        _error = 'Incorrect password.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = user;
      await _secureStorage.write(key: 'current_user_id', value: user.id);
      _authState = AuthState.faceVerification;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Login failed. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  // Simulates facial liveness verification
  Future<bool> completeFaceVerification() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));

    if (_currentUser != null) {
      _currentUser!.isFaceVerified = true;
      await _currentUser!.save();
      _authState = AuthState.authenticated;
    }
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> verifyEmail(String code) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (code == '123456') {
      _currentUser?.isEmailVerified = true;
      await _currentUser?.save();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> changePassword({
    required String current,
    required String newPass,
    required String confirm,
  }) async
  {
    if (newPass != confirm) {
      _error = 'Passwords do not match.';
      notifyListeners();
      return false;
    }
    final storedPass =
        await _secureStorage.read(key: 'password_${_currentUser!.id}');
    if (storedPass != current) {
      _error = 'Current password is incorrect.';
      notifyListeners();
      return false;
    }
    await _secureStorage.write(
        key: 'password_${_currentUser!.id}', value: newPass);
    _error = null;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'current_user_id');
    _authState = AuthState.unauthenticated;
    _currentUser = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
