import 'package:flutter/material.dart';
import 'package:quiz/pages/wait.dart';
import 'package:quiz/utils/firestore_helper.dart';
import 'dart:math';

import 'package:quiz/utils/sudoku_gen.dart';
import 'package:quiz/pages/tabs.dart';
import 'package:quiz/custom_widgets/top_bar.dart';

int selected;
List<int> sudokuPartial;
List<bool> sudokuBool;
final number = ValueNotifier(0);

// Daily Challenge main class
class DailyChallenge extends StatefulWidget {
  final Map<String, dynamic> user;
  final int dailyChallengeDay;
  final int dailyChallengeMonth;
  final int dailyChallengeYear;
  final int gems;
  final DateTime now;

  DailyChallenge({
    @required this.user,
    @required this.dailyChallengeDay,
    @required this.dailyChallengeMonth,
    @required this.dailyChallengeYear,
    @required this.gems,
    @required this.now,
  });

  @override
  _DailyChallengeState createState() => _DailyChallengeState(
        dailyChallengeDay: dailyChallengeDay,
        dailyChallengeMonth: dailyChallengeMonth,
        dailyChallengeYear: dailyChallengeYear,
        now: now,
        gems: gems,
      );
}

class _DailyChallengeState extends State<DailyChallenge> {
  final int dailyChallengeDay;
  final int dailyChallengeMonth;
  final int dailyChallengeYear;
  final int gems;
  final DateTime now;

  List<int> sudoku;
  bool eligible = true;

  _DailyChallengeState({
    @required this.dailyChallengeDay,
    @required this.dailyChallengeMonth,
    @required this.dailyChallengeYear,
    @required this.gems,
    @required this.now,
  });

  @override
  void initState() {
    int day = now.day;
    int month = now.month;
    int year = now.year;
    if (day - dailyChallengeDay < 1 &&
        month - dailyChallengeMonth < 1 &&
        year - dailyChallengeYear < 1) eligible = false;
    if (eligible) {
      selected = -1;
      sudoku = SudokuGen().sudokuGet();
      sudokuPartial = List.from(sudoku);
      sudokuBool = List<bool>.generate(81, (index) => true);
      final Random _rand = Random();
      for (int i = 0; i < 40; i++) {
        int n = _rand.nextInt(80);
        sudokuPartial[n] = 0;
        sudokuBool[n] = false;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget _mainBody = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Center(
          child: SudokuBox(
            sudoku: sudokuPartial,
          ),
        ),
        Container(
          height: 50.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemExtent: 80.0,
            itemCount: 9,
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.zero,
                child: FlatButton(
                  child: Text((index + 1).toString()),
                  shape: CircleBorder(),
                  color: Colors.blue[300],
                  splashColor: Colors.blue[400],
                  onPressed: () {
                    print(index + 1);
                    sudokuPartial[selected] = index + 1;
                    number.value = index + 1;
                  },
                ),
              );
            },
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: RaisedButton(
              color: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              child: Text(
                'Submit',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Submit?'),
                      content: Text(
                          'Once you submit you cannot you cannot undo it.'),
                      actions: <Widget>[
                        FlatButton(
                          child: Text(
                            'Submit',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          onPressed: () => submit(),
                        ),
                        FlatButton(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  }),
            ),
          ),
        ),
      ],
    );

    Widget _later = Center(
      child: Text('No more Challenge Today. Come back Tomorrow!'),
    );

    Widget _body;
    if (eligible)
      _body = _mainBody;
    else
      _body = _later;

    return WillPopScope(
      onWillPop: onBackPress,
      child: Stack(
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
              title: 'Daily Challenge',
              active: GestureDetector(
                child: Container(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 18.0,
                  ),
                ),
                onTap: onBackPress,
              ),
            ),
            body: Container(
              child: _body,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> onBackPress() {
    var alertBox = AlertDialog(
      title: Text('Exit Challenge?'),
      content: Text('If you exit now all your progress will be lost'),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'Cancel',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        FlatButton(
          child: Text(
            'Exit',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => Tabs(user: widget.user)),
            );
          },
        ),
      ],
    );

    if (eligible) {
      return showDialog(
        context: context,
        builder: (context) => alertBox,
      );
    } else {
      return Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Tabs(user: widget.user)),
      );
    }
  }

  void submit() {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Results(
        answer: sudoku,
        user: widget.user,
        gems: gems,
        now: now,
      ),
    ));
  }
}

// Class to show Sudoku puzzle
class SudokuBox extends StatefulWidget {
  final List<int> sudoku;

  SudokuBox({
    @required this.sudoku,
  });

  @override
  _SudokuBoxState createState() => _SudokuBoxState();
}

class _SudokuBoxState extends State<SudokuBox> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: number,
        builder: (context, value, child) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(width: 1.0),
            ),
            height: 315.0,
            margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: GridView.count(
              scrollDirection: Axis.horizontal,
              crossAxisCount: 9,
              shrinkWrap: true,
              children: List.generate(81, (index) {
                Color _border = Colors.black;
                Color _back = Colors.transparent;
                int _num = widget.sudoku[index];
                if (index == selected) {
                  _back = Colors.blue[400];
                }
                if (!sudokuBool[index]) {
                  String _text = _num > 0 ? _num.toString() : ' ';
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selected = index;
                      });
                    },
                    child: Container(
                      height: 35.0,
                      decoration: BoxDecoration(
                          border: Border.all(width: 1.0, color: _border),
                          color: _back),
                      child: Center(child: Text(_text)),
                    ),
                  );
                } else {
                  return Container(
                    height: 35.0,
                    decoration: BoxDecoration(
                        border: Border.all(width: 1.0, color: Colors.black),
                        color: Colors.orange[100]),
                    child: Center(child: Text(_num.toString())),
                  );
                }
              }),
            ),
          );
        });
  }
}

// Class to show Result.
class Results extends StatefulWidget {
  final List<int> answer;
  final Map<String, dynamic> user;
  final int gems;
  final DateTime now;

  Results({
    @required this.answer,
    @required this.user,
    @required this.gems,
    @required this.now,
  });

  @override
  _ResultsState createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  String status;
  Map<String, dynamic> update;
  bool correct;

  @override
  void initState() {
    status = 'fail';
    int day = widget.now.day;
    int month = widget.now.month;
    int year = widget.now.year;
    int updatedGems = widget.gems;
    correct = true;

    for (int i = 0; i < 81; i++) {
      if (widget.answer[i] != sudokuPartial[i]) {
        correct = false;
        break;
      }
    }

    if (correct) updatedGems = updatedGems + 3;

    update = {
      'gems': updatedGems,
      'dailyChallengeDay': day,
      'dailyChallengeMonth': month,
      'dailyChallengeYear': year
    };

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget pass = FutureBuilder(
      future: FirestoreHelper().updateUserDetails(widget.user['email'], update),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            status = 'fail';
            return displayResult('fail');
          } else {
            status = 'correct';
            return displayResult('correct');
          }
        } else
          return Wait(
            waitText: 'Please wait while we check result.',
          );
      },
    );

    Widget _body;

    if (correct)
      _body = pass;
    else {
      status = 'incorrect';
      _body = displayResult('incorrect');
    }

    return WillPopScope(
      onWillPop: () => onBackPress(),
      child: Stack(
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
              title: 'Challenge Result',
              active: GestureDetector(
                child: Container(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 18.0,
                  ),
                ),
                onTap: () => onBackPress(),
              ),
            ),
            body: _body,
          ),
        ],
      ),
    );
  }

  Widget displayResult(String status) {
    Icon icon;
    String text;
    switch (status) {
      case 'correct':
        icon = Icon(
          Icons.done,
          color: Colors.green,
          size: 80.0,
        );
        text = 'CORRECT ANSWER';
        break;
      case 'incorrect':
        icon = Icon(
          Icons.close,
          color: Colors.red,
          size: 80.0,
        );
        text = 'Wrong answer! Try again tomorrow';
        break;
      case 'fail':
        icon = Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 80.0,
        );
        text = 'Failed to update score! Try again please.';
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          child: icon,
        ),
        Container(
          padding: EdgeInsets.all(25.0),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  onBackPress() {
    if (status == 'fail') {
      Navigator.of(context).pop();
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => Tabs(
            user: widget.user,
          ),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }
}
