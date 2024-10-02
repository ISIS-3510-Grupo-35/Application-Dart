import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseAuthServices{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmailAndPassword(String email, String password) async {

    try{
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch(e){
      if(e.code == 'weak-password'){
        if (kDebugMode) {
          print('The password provided is too weak.');
        }
      } else if(e.code == 'email-already-in-use'){
        if (kDebugMode) {
          print('The account already exists for that email.');
        }
      }
    } catch(e){
      if (kDebugMode) {
        print(e);
      }
    }
    return null;
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try{
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch(e){
      if(e.code == 'user-not-found'){
        if (kDebugMode) {
          print('No user found for that email.');
        }
      } else if(e.code == 'wrong-password'){
        if (kDebugMode) {
          print('Wrong password provided for that user.');
        }
      }
    } catch(e){
      if (kDebugMode) {
        print(e);
      }
    }
    return null;
  }
}