import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// SIGN UP with Email & Password
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      debugPrint("STEP 1: Creating auth user");

      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;
      if (user == null) throw Exception("User is null after signup");

      debugPrint("STEP 2: Auth success → UID: ${user.uid}");

      // Write user data to Firestore
      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'name': name,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint("STEP 3: Firestore write success");

      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint("SIGNUP FAILED: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      debugPrint("SIGNUP FAILED: $e");
      rethrow;
    }
  }

  /// LOGIN with Email & Password
  Future<User?> login({required String email, required String password}) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;
      if (user == null) throw Exception("User is null after login");

      debugPrint("LOGIN success → UID: ${user.uid}");
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint("LOGIN FAILED: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      debugPrint("LOGIN FAILED: $e");
      rethrow;
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    try {
      await _auth.signOut();
      debugPrint("User logged out");
    } catch (e) {
      debugPrint("LOGOUT FAILED: $e");
      rethrow;
    }
  }

  Future<void> saveFcmToken() async {
    String? token = await FirebaseMessaging.instance.getToken();

    final user = FirebaseAuth.instance.currentUser;

    if (user != null && token != null) {
      await FirebaseFirestore.instance.collection("users").doc(user.uid).update(
        {"fcmToken": token},
      );
    }
  }

  /// GET CURRENT USER
  User? get currentUser => _auth.currentUser;

  /// OPTIONAL: check if logged in
  bool get isLoggedIn => _auth.currentUser != null;
}
