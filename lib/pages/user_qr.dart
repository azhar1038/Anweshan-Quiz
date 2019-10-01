import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:quiz/pages/registration.dart';

class UserQRPage extends StatelessWidget {
  final DocumentSnapshot userSnapshot;

  UserQRPage({@required this.userSnapshot});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.lightBlue[200],
              Colors.lightBlue[100],
              Colors.white
            ],
          ),
        ),
        child: userSnapshot == null
            ? Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'You are not registered yet!',
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                    SizedBox(
                      width: 200.0,
                      height: 50.0,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        color: Colors.lightBlue,
                        child: Text(
                          'Registration',
                        ),
                        textColor: Colors.white,
                        onPressed: () {
                          Map<String, dynamic> user = {
                            'email': userSnapshot.data['email'],
                            'name': userSnapshot.data['name'],
                            'photoUrl': userSnapshot.data['photoUrl'],
                          };
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  Registration(user: user),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            : Center(
                child: QrImage(
                  data: userSnapshot.documentID,
                  version: QrVersions.auto,
                  size: MediaQuery.of(context).size.width / 1.2,
                ),
              ),
      ),
    );
  }
}
