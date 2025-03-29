import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  Future<bool> doesUserExist(String email) async {
    try {
      final userQuery = await _firestore.collection("users").where("email", isEqualTo: email).get();
      return userQuery.docs.isNotEmpty;
    } catch (e) {
      return false; // Silently fail; assume user doesn’t exist if there’s an error
    }
  }

  Future<void> saveUserLocally(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', user.toJson());
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      // Handle silently; user will still be logged in but not persisted locally
    }
  }

  Future<void> loadStoredUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userData = prefs.getString('user_data');
      if (userData != null && userData.isNotEmpty) {
        _currentUser = UserModel.fromJson(userData);
        notifyListeners();
      }
    } catch (e) {
      // Handle silently; no stored user found
    }
  }

  Future<String> signUp(String name, String email, String password, String phone) async {
    try {
      if (await doesUserExist(email)) {
        return "User already exists. Please log in.";
      }
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        UserModel newUser = UserModel(
          uid: user.uid,
          name: name,
          email: email,
          phone: phone,
          createdAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        await saveUserLocally(newUser);
        return "Signup successful!";
      }
      return "Signup failed unexpectedly.";
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } catch (e) {
      return "An unexpected error occurred. Please try again.";
    }
  }

  Future<String> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection("users").doc(user.uid).get();
        if (userDoc.exists) {
          UserModel loggedInUser = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
          await saveUserLocally(loggedInUser);
          return "Login successful!";
        }
      }
      return "Login failed unexpectedly.";
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } catch (e) {
      return "An unexpected error occurred. Please try again.";
    }
  }

  Future<String> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return "Google Sign-In canceled.";

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection("users").doc(user.uid).get();
        UserModel newUser;

        if (userDoc.exists) {
          newUser = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
        } else {
          newUser = UserModel(
            uid: user.uid,
            name: user.displayName ?? "",
            email: user.email!,
            phone: user.phoneNumber ?? "",
            createdAt: DateTime.now(),
          );
          await _firestore.collection("users").doc(user.uid).set(newUser.toMap());
        }
        await saveUserLocally(newUser);
        return "Google Sign-In successful!";
      }
      return "Google Sign-In failed unexpectedly.";
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } catch (e) {
      return "An unexpected error occurred. Please try again.";
    }
  }

  Future<String> logout() async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
      _currentUser = null;
      notifyListeners();
      return "Logout successful!";
    } catch (e) {
      return "An error occurred during logout. Please try again.";
    }
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return "The email address is badly formatted.";
      case 'user-disabled':
        return "This user has been disabled. Please contact support.";
      case 'user-not-found':
        return "No user found with this email. Please sign up.";
      case 'wrong-password':
        return "Incorrect password. Please try again.";
      case 'email-already-in-use':
        return "This email is already in use. Try logging in instead.";
      case 'weak-password':
        return "The password is too weak. Please choose a stronger password.";
      case 'too-many-requests':
        return "Too many attempts. Please try again later.";
      case 'network-request-failed':
        return "Network error. Please check your internet connection.";
      default:
        return e.message ?? "Authentication failed. Please try again.";
    }
  }
}