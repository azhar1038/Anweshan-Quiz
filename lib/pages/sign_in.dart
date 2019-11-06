import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:quiz/custom_widgets/top_bar.dart';
import 'package:quiz/utils/authentication.dart';
import 'package:quiz/pages/tabs.dart';
import 'package:quiz/utils/firestore_helper.dart';

import 'package:quiz/utils/custom_flare_controller.dart';

GoogleAuth auth = new GoogleAuth();

class SignIn extends StatelessWidget {
  final GoogleLoadController _controller = GoogleLoadController(play: false);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Image.asset(
          'images/background.jpg',
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: TopBar(
            title: 'Sign In',
            active: Icon(Icons.supervised_user_circle, color: Colors.green),
          ),
          body: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      '   Sign In with:',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      if (_controller.play == false) signIn(context);
                    },
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: Center(
                        child: FlareActor(
                          'flare/Google_loader.flr',
                          controller: _controller,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void signIn(BuildContext context) {
    _controller.play = true;
    auth.googleSignIn().then((FirebaseUser user) {
      print(user.email);
      FirestoreHelper().firestoreSignIn(user.email, user.displayName).then((_) {
        Map<String, dynamic> details = {
          'email': user.email,
          'name': user.displayName,
          'photoUrl': user.photoUrl,
        };
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => Tabs(
              user: details,
            ),
          ),
        );
      }).catchError((error) {
        print(error);
        auth.googleSignOut();
        _controller.play = false;
        throw Exception(error);
      });
    }).catchError((error) {
      print(error);
      _controller.play = false;
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Failed to SignIn. Try again.'),
      ));
    });
  }
}
