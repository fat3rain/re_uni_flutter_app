import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Метод для входа
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Метод для регистрации
  Future<User?> register(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(email: email, password: password);
      // Добавляем пользователя в Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'isAdmin': false, // Новый пользователь по умолчанию не админ
      });
      return userCredential.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Метод для получения данных пользователя
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users').doc(uid).get();
      return snapshot.data();
    } catch (e) {
      print(e);
      return null;
    }
  }
}