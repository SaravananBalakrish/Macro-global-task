import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../views/auth/login_screen.dart';

class AuthViewModel with ChangeNotifier {
  late AuthRepository _authRepository;
  late LocalAuthentication _localAuth;
  late FlutterSecureStorage _storage;
  late FirebaseFirestore _firestore;

  UserModel? _currentUser;
  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;
  bool _isSupported = false;
  bool _isPasswordVisible = false;

  AuthViewModel({
    required AuthRepository authRepository,
    LocalAuthentication? localAuth,
    FlutterSecureStorage? storage,
    FirebaseFirestore? firestore,
  })  : _authRepository = authRepository,
        _localAuth = localAuth ?? LocalAuthentication(),
        _storage = storage ?? const FlutterSecureStorage(),
        _firestore = firestore ?? FirebaseFirestore.instance {
    _loadStoredUser();
    checkSupported();
  }

  UserModel? get currentUser => _currentUser;
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  bool get isLoading => _isLoading;
  bool get isSupported => _isSupported;
  bool get isPasswordVisible => _isPasswordVisible;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void checkSupported() async {
    _isSupported = await _localAuth.isDeviceSupported();
    notifyListeners();
  }

  Future<void> _loadStoredUser() async {
    _currentUser = await _authRepository.loadStoredUser();
    notifyListeners();
  }

  Future<void> _storeUserDataInFirestore(String uid, String name, String email, String phone) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _fetchUserData(String uid) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
    if (userDoc.exists) {
      _currentUser = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      notifyListeners();
    }
  }

  Future<void> _storeCredentials(String email, String password) async {
    await _storage.write(key: 'email', value: email);
    await _storage.write(key: 'password', value: password);
  }

  Future<Map<String, String?>> _getStoredCredentials() async {
    String? email = await _storage.read(key: 'email');
    String? password = await _storage.read(key: 'password');
    return {'email': email, 'password': password};
  }

  Future<void> _clearStoredCredentials() async {
    await _storage.delete(key: 'email');
    await _storage.delete(key: 'password');
  }

  Future<String> signUp(String name, String email, String password, String phone) async {
    _isLoading = true;
    notifyListeners();
    try {
      String uid = await _authRepository.signUp(name, email, password, phone);
      await _storeUserDataInFirestore(uid, name, email, phone);
      await _fetchUserData(uid);
      await _storeCredentials(email, password);
      return "Signup successful!";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      String uid = await _authRepository.login(email, password);
      await _fetchUserData(uid);
      await _storeCredentials(email, password);
      return "Login successful!";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithBiometrics() async {
    try {
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to login',
        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
      );

      if (authenticated) {
        Map<String, String?> credentials = await _getStoredCredentials();
        if (credentials['email'] != null && credentials['password'] != null) {
          await login(credentials['email']!, credentials['password']!);
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<String> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      String result = await _authRepository.logout();
      if (result == "Logout successful!") {
        _currentUser = null;
        await _clearStoredCredentials();
      }
      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    try {
      final uid = await _authRepository.signInWithGoogle();
      await _fetchUserData(uid);
      if (_currentUser == null) {
        await _storeUserDataInFirestore(uid, _currentUser!.name, _currentUser!.email, _currentUser!.phone);
      }
      await _storage.write(key: 'email', value: _currentUser!.email);
      await _storage.write(key: 'isGoogleUser', value: 'true');
      return "Google Sign-In successful!";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _isCheckingAuth = true;
  bool _isAuthenticated = false;

  bool get isCheckingAuth => _isCheckingAuth;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> authenticateUser(context) async {
    final user = currentUser;

    if (user == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
      return;
    }

    bool authenticated = await loginWithBiometrics();
    _isAuthenticated = authenticated;
    _isCheckingAuth = false;

    if (!authenticated) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
    notifyListeners();
  }

  Future<bool> loginWithBiometricsForGoogle() async {
    try {
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate with biometrics for Google login',
        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
      );

      if (authenticated) {
        String? email = await _storage.read(key: 'email');
        String? isGoogleUser = await _storage.read(key: 'isGoogleUser');

        if (email != null && isGoogleUser == 'true') {
          await signInWithGoogle();
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
