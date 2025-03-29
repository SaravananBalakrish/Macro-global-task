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

  /// **Check if User Exists in Firestore**
  Future<bool> doesUserExist(String email) async {
    final userQuery = await _firestore.collection("users").where("email", isEqualTo: email).get();
    return userQuery.docs.isNotEmpty;
  }

  /// **Save User Data Locally using SharedPreferences**
  Future<void> saveUserLocally(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', user.toJson());
  }

  /// **Get Stored User Data from SharedPreferences**
  Future<UserModel?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user_data');
    if (userData != null) {
      print("userData :: $userData");
      return UserModel.fromJson(userData);
    }
    notifyListeners();
    return null;
  }

  /// **Signup with Email & Password**
  Future<void> signUp(String name, String email, String password, String phone) async {
    try {
      // **Check if User Exists**
      bool exists = await doesUserExist(email);
      if (exists) {
        throw Exception("User already exists. Please log in.");
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

        // **Store in Firestore**
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());

        // **Save Locally**
        await saveUserLocally(newUser);
        _currentUser = newUser;
      }
      notifyListeners();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// **Login with Email & Password**
  Future<void> login(String email, String password) async {
    try {
      // **Check if User Exists**
      bool exists = await doesUserExist(email);
      if (!exists) {
        throw Exception("No user found for this email. Please sign up.");
      }

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        // **Fetch user details from Firestore**
        DocumentSnapshot userDoc = await _firestore.collection("users").doc(user.uid).get();
        if (userDoc.exists) {
          UserModel loggedInUser = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);

          // **Save user data locally**
          await saveUserLocally(loggedInUser);
          _currentUser = loggedInUser;
        }
      }
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Login failed");
    }
  }

  /// **Google Sign-In**
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // **Check if user exists in Firestore**
        DocumentSnapshot userDoc = await _firestore.collection("users").doc(user.uid).get();

        UserModel newUser;
        if (userDoc.exists) {
          newUser = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
        } else {
          // **Store user in Firestore**
          newUser = UserModel(
            uid: user.uid,
            name: user.displayName ?? "",
            email: user.email!,
            phone: user.phoneNumber ?? "",
            createdAt: DateTime.now(),
          );
          await _firestore.collection("users").doc(user.uid).set(newUser.toMap());
        }

        // **Save user data locally**
        await saveUserLocally(newUser);
        _currentUser = newUser;
      }
      notifyListeners();
    } catch (e) {
      throw Exception("Google Sign-In failed: ${e.toString()}");
    }
  }

  /// **Logout and Clear SharedPreferences**
  Future<void> logout() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();

    // **Clear Local Storage**
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');

    _currentUser = null;
    notifyListeners();
  }
}
