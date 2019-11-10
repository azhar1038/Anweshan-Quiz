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
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.bottomCenter,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: TopBar(
            title: 'Sign In',
            active: Icon(Icons.supervised_user_circle, color: Colors.green),
          ),
          body: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
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
                Container(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'By Signing you agree to our',
                        style: TextStyle(color: Colors.white),
                      ),
                      FlatButton(
                        textColor: Colors.white,
                        child: Text('TERMS OF SERVICE'),
                        onPressed: () => showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => AlertDialog(
                            title: Text('Terms of Service'),
                            content: Text(
                              'By signing in you agree to allow us to use your Email ID and some publicly available data like your Username and Profile picture.\n\n' +
                                  'We WON\'T be disclosing those information to any third party services. Other users of this app can see those details.',
                              textAlign: TextAlign.justify,
                            ),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('OK'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
