import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quiz/custom_widgets/question.dart';
import 'package:http/http.dart' as http;
import 'package:quiz/utils/firestore_helper.dart';

class Tournament extends StatefulWidget {
  final Map<String, dynamic> user, googleUser;

  Tournament({
    @required this.user,
    @required this.googleUser,
  });

  @override
  _TournamentState createState() => _TournamentState(
        email: googleUser['email'],
        consecutiveAce: user['consecutiveAce'],
        gems: user['gems'],
        life: user['life'],
        tournamentScore: user['tournamentScore'],
      );
}

class _TournamentState extends State<Tournament> {
  final String email;
  final int consecutiveAce;
  final int gems;
  final int life;
  final int tournamentScore;

  int _life;
  int _correct, _incorrect;
  bool _usedLife;
  bool _popup;
  bool _allowExit;
  http.Response _image;

  _TournamentState({
    this.email,
    this.tournamentScore,
    this.gems,
    this.consecutiveAce,
    this.life,
  });

  @override
  void initState() {
    super.initState();
    _life = life;
    _correct = 0;
    _incorrect = 0;
    _usedLife = false;
    _popup = false;
    _allowExit = false;
    print('INIT STATE');
  }

  Future<DocumentSnapshot> loadQuestion(int questionNumber) {
    return Firestore.instance
        .document('questions/question$questionNumber')
        .get()
        .then((DocumentSnapshot snapshot) async {
      if (snapshot['url'].isNotEmpty) _image = await http.get(snapshot['url']);
      return snapshot;
    });
  }

  AlertDialog getAlertDialog(String correct) {
    return AlertDialog(
      title: Text('Wrong answer! Use Life?'),
      content: Text(
        'Correct answer is \'$correct\'. Would you like to use your life?',
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      actions: <Widget>[
        FlatButton(
            child: Text('No'),
            textColor: Colors.red,
            onPressed: () {
              _popup = false;
              Navigator.of(context).pop();
            }),
        FlatButton(
            child: Text('Yes'),
            textColor: Colors.green,
            onPressed: () {
              _incorrect--;
              _correct++;
              _life--;
              _usedLife = true;
              _popup = false;
              Navigator.of(context).pop();
            }),
      ],
    );
  }

  Question buildQuestion(DocumentSnapshot question, int questionNum) {
    return Question(
      question: question,
      image: _image,
      onCorrect: () {
        _correct++;
      },
      onIncorrect: (String correct) {
        _incorrect++;
        if (_life > 0 && !_usedLife) {
          _popup = true;
          showDialog(
            context: context,
            builder: (context) {
              return WillPopScope(
                onWillPop: () async {
                  _popup = false;
                  return true;
                },
                child: getAlertDialog(correct),
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: WillPopScope(
        onWillPop: () async {
          if (_allowExit)
            return true;
          else
            return false;
        },
        child: Container(
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder(
              stream:
                  Firestore.instance.document('quiz_info/question').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    int _num = snapshot.data['current'];
                    print(_num);
                    if (_popup) Navigator.of(context).pop();
                    if (_num == -1) {
                      _allowExit = true;
                      return Center(
                        child: Text(
                          snapshot.data['message'],
                          style: TextStyle(fontSize: 20.0),
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else if (_num == 0) {
                      _allowExit = false;
                      return Center(
                        child: Text(
                          "Get Ready! Quiz is about to start. You cannot exit until quiz is over.",
                          style: TextStyle(fontSize: 20.0),
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else if (_num > 0 && _num < 11) {
                      _allowExit = false;
                      return FutureBuilder(
                        future: loadQuestion(_num),
                        builder: (BuildContext context,
                            AsyncSnapshot<DocumentSnapshot> question) {
                          if (question.connectionState ==
                              ConnectionState.done) {
                            return buildQuestion(question.data, _num);
                          }
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      );
                    } else if (_num == 11) {
                      int tempCorrect = _correct;
                      _correct = 0;
                      _allowExit = false;
                      int newTournamentScore = tournamentScore + tempCorrect;
                      int newGems = gems;
                      int newConsecutiveAce = consecutiveAce;
                      int newLife = _life;
                      if (tempCorrect == 10) {
                        newGems += 10;
                        newConsecutiveAce += 1;
                        if (newConsecutiveAce >= 2) {
                          newConsecutiveAce = 0;
                          newLife += 1;
                        }
                      }
                      Map<String, dynamic> update = {
                        'consecutiveAce': newConsecutiveAce,
                        'gems': newGems,
                        'life': newLife,
                        'tournamentScore': newTournamentScore,
                      };
                      return Center(
                        child: FutureBuilder(
                          future: FirestoreHelper().updateUserDetails(
                              widget.googleUser['email'], update),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasError) {
                                return Text(
                                  'Something went Wrong! Please take a screenshot of this page and Contact Support. Score=$_correct, Life=$_life',
                                  textAlign: TextAlign.center,
                                );
                              }
                              _allowExit = true;
                              return Text(
                                '$tempCorrect / 10',
                                style: TextStyle(
                                  fontSize: 50.0,
                                  fontWeight: FontWeight.w300,
                                ),
                              );
                            }
                            return CircularProgressIndicator();
                          },
                        ),
                      );
                    }
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return Center(
                  child: Text('Connection Deactivated!'),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
