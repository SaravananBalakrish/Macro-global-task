import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> doesUserExist(String email) async {
    try {
      final userQuery = await _firestore.collection("users").where("email", isEqualTo: email).get();
      return userQuery.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> saveUserLocally(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', user.toJson());
  }

  Future<UserModel?> loadStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user_data');
    return userData != null && userData.isNotEmpty ? UserModel.fromJson(userData) : null;
  }

  Future<String> signUp(String name, String email, String password, String phone) async {
    try {
      if (await doesUserExist(email)) return "User already exists. Please log in.";

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
      return _handleFirebaseAuthError(e);
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
        } else {
          return "User data not found. Please contact support.";
        }
      }
      return "Login failed unexpectedly.";
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthError(e);
    } catch (e) {
      return "An unexpected error occurred. Please check your connection.";
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
      return _handleFirebaseAuthError(e);
    } catch (e) {
      return "An unexpected error occurred during Google Sign-In.";
    }
  }

  Future<String> logout() async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
      return "Logout successful!";
    } catch (e) {
      return "Logout failed. Please try again.";
    }
  }

  String _handleFirebaseAuthError(FirebaseAuthException e) {
    debugPrint("Firebase Auth Error: ${e.code}");
    switch (e.code) {
      case "invalid-email":
        return "Invalid email format. Please check and try again.";
      case "user-disabled":
        return "This user account has been disabled.";
      case "user-not-found":
        return "No user found with this email.";
      case "wrong-password":
        return "Incorrect password. Please try again.";
      case "email-already-in-use":
        return "This email is already registered. Try logging in.";
      case "weak-password":
        return "Password is too weak. Try a stronger one.";
      case "network-request-failed":
        return "Network error. Please check your connection.";
      case "operation-not-allowed":
        return "Sign-in method is not enabled in Firebase.";
      case "too-many-requests":
        return "Too many failed login attempts. Try again later.";
      case "credential-already-in-use":
        return "This credential is already associated with a different user.";
      case "requires-recent-login":
        return "Please log in again before performing this action.";
      case "invalid-credential":
        return "Invalid credentials. Please check and try again.";
      case "account-exists-with-different-credential":
        return "An account with this email exists but is linked to a different sign-in method.";
      case "invalid-verification-code":
        return "The verification code is incorrect. Try again.";
      case "invalid-verification-id":
        return "The verification ID is incorrect. Try again.";
      default:
        return "An unexpected error occurred: ${e.message}";
    }
  }
}
