import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quiz/custom_widgets/countdown.dart';
import 'package:quiz/custom_widgets/quiz_quartet.dart';

class Question extends StatefulWidget {
  final DocumentSnapshot question;
  final http.Response image;
  final VoidCallback onCorrect;
  final Function(String) onIncorrect;

  const Question({
    Key key,
    @required this.question,
    @required this.image,
    this.onCorrect,
    this.onIncorrect,
  })  : assert(question != null),
        super(key: key);

  @override
  _QuestionState createState() => _QuestionState();
}

class _QuestionState extends State<Question>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  bool _showAnswer;
  int _selected;

  @override
  void initState() {
    _showAnswer = false;
    _selected = 0;
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: 10,
      ),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (_selected == widget.question['answer'])
            widget.onCorrect();
          else
            widget.onIncorrect(getCorrectAnswer());
          setState(() {
            _showAnswer = true;
          });
        }
      });
    _controller.forward();
  }

  String getCorrectAnswer() {
    return widget.question['opt${widget.question['answer']}'];
  }

  Widget getPicture() {
    if (widget.question['url'].isEmpty) return Spacer();
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(15.0),
        child: Image.memory(
          widget.image.bodyBytes,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0),
          child: Text(
            widget.question['question'],
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        getPicture(),
        Countdown(
          controller: _controller,
          height: 20.0,
        ),
        QuizQuartet(
          opt1: widget.question['opt1'],
          opt2: widget.question['opt2'],
          opt3: widget.question['opt3'],
          opt4: widget.question['opt4'],
          answer: widget.question['answer'],
          showAnswer: _showAnswer,
          onPressed: (int index) {
            _selected = index;
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    if (_controller.status != AnimationStatus.completed) {
      if (_selected == widget.question['answer'])
        widget.onCorrect();
      else
        widget.onIncorrect(getCorrectAnswer());
    }
    _controller.dispose();
    super.dispose();
  }
}
