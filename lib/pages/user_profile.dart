import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quiz/custom_widgets/wait_button.dart';
import 'package:quiz/pages/sign_in.dart';
import 'package:quiz/pages/user_qr.dart';
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
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.lightBlue[300],
              Colors.lightBlue[100],
              Colors.white,
            ],
          ),
        ),
        child: _Profile(
          user: user,
        ),
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

class __ProfileState extends State<_Profile> with TickerProviderStateMixin {
  Map<String, dynamic> userDetails;
  AnimationController _passController, _lifeController, _logoutController;

  @override
  void initState() {
    super.initState();
    Firestore.instance
        .document('users/${widget.user['email']}')
        .get()
        .then((DocumentSnapshot snapshot) {
      userDetails = snapshot.data;
      _passController = AnimationController(
        duration: Duration(milliseconds: 200),
        vsync: this,
      );
      _lifeController = AnimationController(
        duration: Duration(milliseconds: 200),
        vsync: this,
      );
      _logoutController = AnimationController(
        duration: Duration(milliseconds: 200),
        vsync: this,
      );
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
                      Container(
                        alignment: Alignment.center,
                        child: WaitButton(
                          key: UniqueKey(),
                          child: Text(
                            'Anweshan Pass',
                            style: TextStyle(color: Colors.white),
                          ),
                          controller: _passController,
                          color: Colors.lightBlue,
                          width: 200.0,
                          height: 50.0,
                          onPressed: _userPass,
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: WaitButton(
                          key: UniqueKey(),
                          child: Text(
                            'Buy Life',
                            style: TextStyle(color: Colors.white),
                          ),
                          controller: _lifeController,
                          color: Colors.lightBlue,
                          width: 200.0,
                          height: 50.0,
                          onPressed: _buyLife,
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: WaitButton(
                          key: UniqueKey(),
                          child: Text(
                            'Logout',
                            style: TextStyle(color: Colors.white),
                          ),
                          controller: _logoutController,
                          color: Colors.lightBlue,
                          width: 200.0,
                          height: 50.0,
                          onPressed: _logout,
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

  void _logout() {
    GoogleAuth().googleSignOut().then((_) {
      FirestoreHelper().firestoreSignOut(widget.user['email']).then((_) {
        _logoutController.reverse();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => SignIn()),
          (Route<dynamic> routes) => false,
        );
      });
    }).catchError((error) {
      showSnackbar('Failed to logout. Try again.');
      _logoutController.reverse();
    }).timeout(Duration(seconds: 5), onTimeout: () {
      showSnackbar('Failed to logout. Try again.');
      _logoutController.reverse();
    });
  }

  void _userPass() {
    DocumentSnapshot doc;
    Firestore.instance
        .collection('registered')
        .where('email', isEqualTo: widget.user['email'])
        .getDocuments()
        .then((snapshot) {
      if (snapshot != null) {
        doc = snapshot.documents[0];
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => UserQRPage(userSnapshot: doc),
        ),
      );
    });
  }

  void _buyLife() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Buy Life?'),
        content: Text('Would you like to spend 10 gems to purchase 1 life?'),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.red,
            child: Text('No'),
            onPressed: () {
              _lifeController.reverse();
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            textColor: Colors.green,
            child: Text('Yes'),
            onPressed: () {
              FirestoreHelper().buyLife(widget.user['email']).then((_) {
                _lifeController.reverse();
                setState(() {
                  userDetails['gems'] = userDetails['gems'] - 10;
                  userDetails['life'] = userDetails['life'] + 1;
                });
              }).catchError((error) {
                print(error.cause);
                showSnackbar('Failed to complete Transaction.');
                _lifeController.reverse();
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void showSnackbar(String message) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
}
