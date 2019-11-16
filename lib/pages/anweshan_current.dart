import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quiz/custom_widgets/wait_button.dart';
import 'package:quiz/pages/anweshan_prev.dart';

import 'package:quiz/pages/registration.dart';
import 'package:quiz/pages/user_qr.dart';

class AnweshanCurrent extends StatefulWidget {
  final Map<String, dynamic> user;

  AnweshanCurrent({@required this.user});

  @override
  _AnweshanCurrentState createState() => _AnweshanCurrentState();
}

class _AnweshanCurrentState extends State<AnweshanCurrent>
    with SingleTickerProviderStateMixin {
  AnimationController _regController;

  @override
  void initState() {
    super.initState();
    _regController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200.withOpacity(0.1),
        ),
        child: Container(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              height: 150.0,
              alignment: Alignment.center,
              child: Text(
                'ANWESHAN 2020',
                style: TextStyle(
                  fontSize: 30.0,
                  color: Colors.blue[900],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(20.0),
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 200.0,
                      height: 50.0,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        color: Colors.lightBlue,
                        child: Text(
                          'Events',
                        ),
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AnweshanPrev(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Container(
                  //   margin: EdgeInsets.all(20.0),
                  //   alignment: Alignment.center,
                  //   child: SizedBox(
                  //     width: 200.0,
                  //     height: 50.0,
                  //     child: FlatButton(
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(25.0),
                  //       ),
                  //       color: Colors.lightBlue,
                  //       child: Text(
                  //         'Registration',
                  //       ),
                  //       textColor: Colors.white,
                  //       onPressed: () {
                  //         Navigator.of(context).push(
                  //           MaterialPageRoute(
                  //             builder: (context) =>
                  //                 Registration(user: widget.user),
                  //           ),
                  //         );
                  //       },
                  //     ),
                  //   ),
                  // ),

                  Container(
                    alignment: Alignment.center,
                    child: WaitButton(
                      key: UniqueKey(),
                      child: Text(
                        'Registration',
                        style: TextStyle(color: Colors.white),
                      ),
                      controller: _regController,
                      color: Colors.lightBlue,
                      width: 200.0,
                      height: 50.0,
                      onPressed: _userReg,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )),
      ),
    );
  }

  void _userReg() async {
    Firestore.instance
        .collection('registered')
        .where('email', isEqualTo: widget.user['email'])
        .getDocuments()
        .then((snapshot) {
      _regController.reverse();
      if (snapshot.documents.length > 0) {
        DocumentSnapshot doc = snapshot.documents[0];
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UserQRPage(userSnapshot: doc),
          ),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Registration(
              user: widget.user,
            ),
          ),
        );
      }
    }).catchError((error) {
      print(error);
      showSnackbar('Failed to get pass. Try again.');
      _regController.reverse();
    }).timeout(Duration(seconds: 5), onTimeout: () {
      showSnackbar('Server timeout. Try again.');
      _regController.reverse();
    });
  }

  void showSnackbar(String message) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
}
