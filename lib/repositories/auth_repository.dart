import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'dart:developer' as developer;

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> doesUserExist(String email) async {
    try {
      final userQuery = await _firestore.collection("users").where("email", isEqualTo: email).get();
      return userQuery.docs.isNotEmpty;
    } catch (e, stackTrace) {
      developer.log('Error checking user existence', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<void> saveUserLocally(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', user.toJson());
    } catch (e, stackTrace) {
      developer.log('Error saving user locally', error: e, stackTrace: stackTrace);
    }
  }

  Future<UserModel?> loadStoredUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userData = prefs.getString('user_data');
      return userData != null && userData.isNotEmpty ? UserModel.fromJson(userData) : null;
    } catch (e, stackTrace) {
      developer.log('Error loading stored user', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<String> signUp(String name, String email, String password, String phone) async {
    try {
      bool exists = await doesUserExist(email);
      if (exists) {
        throw Exception("User already exists. Please log in.");
      }
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // await user.sendEmailVerification();
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'phone': phone,
          'userId': user.uid,
        });
        return 'Signup successful! Please verify your email before logging in.';
      }
      return 'Signup failed. Try again later.';
    } catch (e, stackTrace) {
      developer.log('Error signing up', error: e, stackTrace: stackTrace);
      return e.toString();
    }
  }

  Future<String> login(String email, String password) async {
    try {
      // Check if the user exists in Firebase Authentication
      List<String> signInMethods = await _auth.fetchSignInMethodsForEmail(email);
      if (signInMethods.isEmpty) {
        return "No account found. Please sign up.";
      }

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        // if (!user.emailVerified) {
        //   await user.sendEmailVerification();
        //   return "Please verify your email. A new verification email has been sent.";
        // }
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
    } catch (e, stackTrace) {
      developer.log('Error logging in', error: e, stackTrace: stackTrace);
      return "An unexpected error occurred. Please check your connection.";
    }
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) throw Exception("Google Sign-In canceled.");
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
        bool isNewUser = !userDoc.exists;
        if (isNewUser) {
          newUser = UserModel(
            uid: user.uid,
            name: user.displayName ?? "",
            email: user.email!,
            phone: user.phoneNumber ?? "",
            createdAt: DateTime.now(),
          );
          await _firestore.collection("users").doc(user.uid).set(newUser.toMap());
        } else {
          newUser = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
        }
        await saveUserLocally(newUser);
        return {
          'userCredential': userCredential,
          'isNewUser': isNewUser,
        };
      }
      throw Exception("Google Sign-In failed unexpectedly.");
    } catch (e, stackTrace) {
      developer.log('Error signing in with Google', error: e, stackTrace: stackTrace);
      throw Exception("An unexpected error occurred during Google Sign-In: $e");
    }
  }

  Future<String> logout() async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
      return "Logout successful!";
    } catch (e, stackTrace) {
      developer.log('Error logging out', error: e, stackTrace: stackTrace);
      return "Logout failed. Please try again.";
    }
  }
}