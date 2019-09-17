import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firestore_helper.dart';

class GoogleAuth{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = new GoogleSignIn();

  Future<FirebaseUser> googleSignIn() async {
    try{
      print("Trying to sign in");
      GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
      print("Signin");
      GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
      print("authentication");

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken
      );

      FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
      return user;
    } catch (e){
      throw GoogleAuthException('GOOGLE_AUTH_EXCEPTION: Failed to SignIn => $e');
    }
  }

  void googleSignOut() async{
    try{
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e){
      throw GoogleAuthException('GOOGLE_AUTH_EXCEPTION: Failed to SignOut => $e');
    }
    
  }

  // TODO: Remove deleteAccount.
  void deleteAccount() async{
    FirebaseUser user = await getUser();
    FirestoreHelper().deleteAccount(user.email);
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  Future<FirebaseUser> getUser(){
    try{
      return FirebaseAuth.instance.currentUser();
    } catch (e) {
      throw GoogleAuthException('GOOGLE_AUTH_EXCEPTION: Failed to get user => $e');
    }
  }
}

class GoogleAuthException implements Exception{
  String cause;
  GoogleAuthException(this.cause);
}