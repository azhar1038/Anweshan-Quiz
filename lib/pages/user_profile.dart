import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quiz/pages/sign_in.dart';
import 'package:quiz/utils/authentication.dart';
import 'package:quiz/utils/firestore_helper.dart';

class UserProfile extends StatelessWidget {
  final Map<String, dynamic> user;

  UserProfile({
    @required this.user,
  });

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
        child: _Profile(user: user),
      ),
    );
  }
}

class _Profile extends StatefulWidget {
  final Map<String, dynamic> user;

  _Profile({
    @required this.user,
  });

  @override
  __ProfileState createState() => __ProfileState();
}

class __ProfileState extends State<_Profile> {
  Map<String, dynamic> userDetails;

  @override
  void initState() {
    super.initState();
    Firestore.instance
        .document('users/${widget.user['email']}')
        .get()
        .then((DocumentSnapshot snapshot) {
      userDetails = snapshot.data;
      setState(() {});
    });
  }

  TextStyle header = TextStyle(
    fontSize: 25.0,
    fontWeight: FontWeight.w500,
  );

  TextStyle detail = TextStyle(
    fontSize: 20.0,
  );

  @override
  Widget build(BuildContext context) {
    return userDetails == null
        ? Container(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          )
        : Padding(
            padding: EdgeInsets.only(
              top: 20.0,
              left: 8.9,
              right: 8.0,
              bottom: 8.0,
            ),
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(16.0),
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(
                              widget.user['photoUrl'],
                            ),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: Text(
                          userDetails['name'],
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Tournament Score',
                              style: header,
                            ),
                            Text(
                              userDetails['tournamentScore'].toString(),
                              style: detail,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Total Gems',
                              style: header,
                            ),
                            Text(
                              userDetails['gems'].toString(),
                              style: detail,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Remaining Lifes',
                              style: header,
                            ),
                            Text(
                              userDetails['life'].toString(),
                              style: detail,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Today\'s Challenge',
                              style: header,
                            ),
                            Text(
                              dailyChallengeStatus(),
                              style: detail,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      SizedBox(
                        height: 50,
                        width: 150,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          color: Colors.lightBlue,
                          child: Text(
                            'Anweshan Pass',
                          ),
                          textColor: Colors.white,
                          onPressed: () {},
                        ),
                      ),
                      SizedBox(
                        height: 50.0,
                        width: 150.0,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          color: Colors.lightBlue,
                          child: Text(
                            'Logout',
                          ),
                          textColor: Colors.white,
                          onPressed: () {
                            GoogleAuth().googleSignOut().then((_) {
                              FirestoreHelper()
                                  .firestoreSignOut(widget.user['email'])
                                  .then((_) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignIn(),
                                  ),
                                  (Route<dynamic> route) => false,
                                );
                              });
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  String dailyChallengeStatus() {
    DateTime now = DateTime.now();
    if (now.day == userDetails['dailyChallengeDay'] &&
        now.month == userDetails['dailyChallengeMonth'] &&
        now.year == userDetails['dailyChallengeYear']) {
      return 'Complete';
    }
    return 'Incomplete';
  }
}
