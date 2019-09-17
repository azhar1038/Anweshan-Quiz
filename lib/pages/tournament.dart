import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import 'package:quiz/custom_widgets/quiz_quartet.dart';
import 'package:quiz/custom_widgets/top_bar.dart';
import 'package:quiz/custom_widgets/countdown.dart';
import 'package:quiz/pages/tabs.dart';
import 'package:quiz/utils/firestore_helper.dart';

int _life;
int _correct = 0;
bool _usedLife = false;
int _selected = 0;
bool _allowExit = false;

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
  String pageStatus;

  _TournamentState({
    this.email,
    this.tournamentScore,
    this.gems,
    this.consecutiveAce,
    this.life,
  });

  @override
  void initState() {
    _life = life;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var _body = StreamBuilder(
      stream: Firestore.instance.document('quiz_info/question').snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            _selected = 0;
            int num = snapshot.data['current'];
            print("Question $num");
            if (num > 0 && num < 11) {
              pageStatus = 'active';
              return FutureBuilder(
                future: getQuestionDetails(num),
                builder:
                    (context, AsyncSnapshot<Map<String, dynamic>> question) {
                  if (question.connectionState == ConnectionState.done) {
                    if (question.hasError) {
                      return Text('Question error');
                    } else {
                      return _Question(question: question.data);
                    }
                  }
                  return CircularProgressIndicator();
                },
              );
            } else if (num == 0) {
              pageStatus = 'message';
              return Text(
                snapshot.data['message'],
                style: TextStyle(fontSize: 20.0),
              );
            } else if (num == 11) {
              pageStatus = 'score';
              int newTournamentScore = tournamentScore + _correct;
              int newGems = gems;
              int newConsecutiveAce = consecutiveAce;
              int newLife = _life;
              if (_correct == 10) {
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
              return FutureBuilder(
                future: FirestoreHelper().updateUserDetails(email, update),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Text(
                          'Something went Wrong! Please take a screenshot of this page and Contact Support. Score=$_correct, Life=$_life');
                    }
                    _allowExit = true;
                    return Text(
                      '$_correct / 10',
                      style: TextStyle(
                        fontSize: 50.0,
                        fontWeight: FontWeight.w300,
                      ),
                    );
                  }
                  _allowExit = false;
                  return CircularProgressIndicator();
                },
              );
            } else if (num == -1) {
              return CircularProgressIndicator();
            } else {
              return Text('Unknown Question number.');
            }
          }
          return CircularProgressIndicator();
        }
        return Text('Connection Inactive');
      },
    );

    return WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
        backgroundColor: Colors.lightBlue[200],
        appBar: TopBar(
          title: 'Tournament',
          active: Icon(Icons.access_time),
        ),
        body: Center(child: _body),
      ),
    );
  }

  Future<bool> onBackPressed() {
    if (pageStatus == 'message')
      Navigator.of(context).pop();
    else if (pageStatus == 'score') {
      if (_allowExit) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => Tabs(
              user: widget.googleUser,
            ),
          ),
          (Route<dynamic> route) => false,
        );
      } else {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text('Please Wait'),
          ),
        );
      }
    } else if (pageStatus == 'active')
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot exit until Tournament is over.'),
        ),
      );
  }

  Future<Map<String, dynamic>> getQuestionDetails(int num) async {
    http.Response response;
    Map<String, dynamic> question =
        (await Firestore.instance.document('questions/question$num').get())
            .data;
    if (!question['url'].isEmpty) {
      response = await http.get(question['url']);
    }
    question['image'] = response;
    return question;
  }

  @override
  void dispose() {
    super.dispose();
  }
}

//Displays Question with options
//Controls Animation of linear Timer
//Updates _selected on click of each option

class _Question extends StatefulWidget {
  final Map<String, dynamic> question;

  _Question({
    this.question,
  });

  @override
  _QuestionState createState() => _QuestionState(
        question: question['question'],
        opt1: question['opt1'],
        opt2: question['opt2'],
        opt3: question['opt3'],
        opt4: question['opt4'],
        answer: question['answer'],
        image: question['image'],
      );
}

class _QuestionState extends State<_Question>
    with SingleTickerProviderStateMixin {
  final String question;
  final String opt1;
  final String opt2;
  final String opt3;
  final String opt4;
  final http.Response image;
  final int answer;
  AnimationController controller;
  bool showAnswer = false;

  _QuestionState({
    this.question,
    this.opt1,
    this.opt2,
    this.opt3,
    this.opt4,
    this.image,
    this.answer,
  });

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(seconds: 10), vsync: this);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          showAnswer = true;
        });
        if (_selected == answer) {
          _correct += 1;
        } else {
          if (_life > 0 && !_usedLife) {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Wrong answer! Use Life?',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                action: SnackBarAction(
                  label: 'Yes',
                  onPressed: () {
                    _correct += 1;
                    _life -= 1;
                    _usedLife = true;
                  },
                ),
              ),
            );
          }
        }
        print('Correct = $_correct');
      }
    });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    Widget picture = image == null
        ? Spacer()
        : Expanded(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(10.0),
              child: Image.memory(
                image.bodyBytes,
              ),
            ),
          );
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.lightBlue[200], Colors.lightBlue[100], Colors.white],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
            child: Text(
              question,
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          picture,
          Countdown(
            controller: controller,
            height: 20.0,
          ),
          QuizQuartet(
            opt1: opt1,
            opt2: opt2,
            opt3: opt3,
            opt4: opt4,
            answer: answer,
            showAnswer: showAnswer,
            onPressed: (int index) {
              _selected = index;
              print(_selected);
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
