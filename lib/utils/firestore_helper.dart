import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'referral_helper.dart';

class FirestoreHelper {
  Future<void> firestoreSignIn(String mailId, String name) {
    DateTime now = DateTime.now();
    int day = now.day - 1;
    int month = now.month;
    int year = now.year;
    return Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentReference document = Firestore.instance.document('users/$mailId');
      DocumentSnapshot snapshot = await transaction.get(document);
      if (snapshot.data == null) {
        ReferralHelper referralHelper = new ReferralHelper();
        Uri deepLink = await referralHelper.retrieveDynamicLink(mailId);
        String deepLinkString = deepLink.toString();
        print('deepLink is $deepLinkString');
        if (deepLink != null) {
          String referrerMailId = deepLink.queryParameters['referrer'];
          if (referrerMailId != mailId) {
            DocumentReference referrer =
                Firestore.instance.document('users/$referrerMailId');
            DocumentSnapshot referrerSnapshot = await transaction.get(referrer);
            if (referrerSnapshot.data != null) {
              int gems = referrerSnapshot.data['gems'] + 5;
              await transaction.update(referrer, {'gems': gems});
            }
          }
        }
        await transaction.set(document, {
          'name': name,
          'signed': true,
          'gems': 0,
          'life': 2,
          'usedLife': false,
          'tournamentScore': 0,
          'consecutiveAce': 0,
          'dailyChallengeDay': day,
          'dailyChallengeMonth': month,
          'dailyChallengeYear': year,
        });
      } else {
        await transaction.update(document, {'signed': true});
      }
    }).catchError((error) {
      throw FirestoreHelperException(
          "FIRESTORE_HELPER_EXCEPTION: Failed to SignIn => $error");
    });
  }

  Future<void> firestoreSignOut(String mailId) {
    return Firestore.instance
        .document('users/$mailId')
        .updateData({'signed': false});
  }

  Future<Map<String, dynamic>> getUserDetails(String mailId) async {
    return Firestore.instance.document('users/$mailId').get().then((snapshot) {
      if (snapshot.data == null)
        throw FirestoreHelperException("User details missing from database");
      return snapshot.data;
    }).timeout(Duration(seconds: 5), onTimeout: () {
      throw FirestoreHelperException("Out of time. Try again.");
    }).catchError((e) {
      throw FirestoreHelperException(
          "FIRESTORE_HELPER_EXCEPTION: Failed to get user details => ${e.cause}");
    });
  }

  Future<void> updateUserDetails(String mailId, Map<String, dynamic> m) {
    DocumentReference document = Firestore.instance.document('users/$mailId');
    return document.updateData(m).catchError((error) {
      throw FirestoreHelperException(
          "FIRESTORE_HELPER_EXCEPTION: Failed to update user details => $error");
    });
  }

  Future<void> buyLife(String mailId) {
    return Firestore.instance.runTransaction((Transaction t) {
      DocumentReference d = Firestore.instance.document('users/$mailId');
      return t.get(d).then((snapshot) {
        if (snapshot.data['gems'] >= 10) {
          t.update(
            d,
            {
              'gems': snapshot.data['gems'] - 10,
              'life': snapshot.data['life'] + 1
            },
          );
        }else{
          throw FirestoreHelperException('Insufficient amount of gems');
        }
      }).catchError((error){
        throw FirestoreHelperException('Failed to update details.');
      });
    }).catchError((error){
      throw FirestoreHelperException('Failed to complete transaction.');
    });
  }
}

class FirestoreHelperException implements Exception {
  String cause;
  FirestoreHelperException(this.cause);
}
