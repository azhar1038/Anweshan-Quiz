import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
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
        print('CORRECT: $_correct');
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
        // child: Stack(
        //   children: <Widget>[
        //     Image.asset(
        //       'images/background.jpg',
        //       fit: BoxFit.cover,
        //       height: MediaQuery.of(context).size.height,
        //       width: MediaQuery.of(context).size.width,
        //       alignment: Alignment.bottomCenter,
        //     ),
        child: Container(
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
                    return MessageDisplay(
                      message: snapshot.data['message'],
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
                        if (question.connectionState == ConnectionState.done) {
                          return buildQuestion(question.data, _num);
                        }
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    );
                  } else if (_num == 11) {
                    int tempCorrect = _correct;
                    int tempIncorrect = _incorrect;
                    _correct = 0;
                    _incorrect = 0;
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
                            return ResultDisplay(
                              correct: tempCorrect,
                              incorrect: tempIncorrect,
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
        //],
        //),
      ),
    );
  }
}

class MessageDisplay extends StatelessWidget {
  final String message;

  MessageDisplay({
    @required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 200,
            width: 200,
            child: FlareActor(
              'flare/Animated orb.flr',
              fit: BoxFit.contain,
              animation: 'Aura',
            ),
          ),
          Text(
            message,
            style: TextStyle(fontSize: 20.0),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ResultDisplay extends StatelessWidget {
  final int correct, incorrect;
  ResultDisplay({
    @required this.correct,
    @required this.incorrect,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "Your Score: ",
              style: textStyle,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                correct.toString(),
                style: TextStyle(
                  fontSize: 70,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * correct * 0.1,
                  color: Colors.green,
                  height: 30,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * incorrect * 0.1,
                  color: Colors.red,
                  height: 30,
                ),
                Container(
                  width: MediaQuery.of(context).size.width *
                      (10 - correct - incorrect) *
                      0.1,
                  color: Colors.yellow,
                  height: 30,
                )
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Correct',
                        style: textStyle,
                      ),
                      Text(
                        correct.toString(),
                        style: textStyle,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Incorrect',
                        style: textStyle,
                      ),
                      Text(
                        incorrect.toString(),
                        style: textStyle,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Not Attempted',
                        style: textStyle,
                      ),
                      Text(
                        (10 - correct - incorrect).toString(),
                        style: textStyle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
