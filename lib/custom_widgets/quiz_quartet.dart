import 'package:flutter/material.dart';

class QuizQuartet extends StatefulWidget {
  final String opt1, opt2, opt3, opt4;
  final int answer;
  final bool showAnswer;
  final Function(int) onPressed;

  QuizQuartet({
    @required this.opt1,
    @required this.opt2,
    @required this.opt3,
    @required this.opt4,
    @required this.answer,
    @required this.onPressed,
    this.showAnswer = false,
  });

  @override
  _QuizQuartetState createState() => _QuizQuartetState();
}

class _QuizQuartetState extends State<QuizQuartet> {
  static const Color buttonColor = Colors.blue;
  static const Color buttonSelectedColor = Colors.amber;
  static const Color buttonCorrectColor = Colors.green;
  static const Color buttonWrongColor = Colors.red;
  static const Color buttonTextColor = Colors.black;

  int selected = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0),

      // width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: columnChildren(),
      ),
    );
  }

  optionClick(int index) {
    if (!widget.showAnswer) {
      widget.onPressed(index);
      setState(() {
        selected = index;
      });
    }
  }

  MaterialColor decideColor(int index) {
    if (widget.showAnswer) {
      if (widget.answer == index) {
        return buttonCorrectColor;
      } else if (selected == index) {
        return buttonWrongColor;
      } else
        return buttonColor;
    } else {
      if (selected == index) {
        return buttonSelectedColor;
      } else
        return buttonColor;
    }
  }

  List<Widget> columnChildren() {
    List<Widget> children = [];
    List<String> text = [widget.opt1, widget.opt2, widget.opt3, widget.opt4];
    for (int i = 0; i < 4; i++) {
      Function fun = widget.showAnswer?null:()=>optionClick(i+1);
      MaterialColor c = decideColor(i+1);
      children.add(
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: SizedBox(
            width: double.infinity,
            height: 40.0,
            child: OutlineButton(
              highlightedBorderColor: c,
              highlightColor: c[200],
              splashColor: c[300],
              disabledBorderColor: c,
              disabledTextColor: c,
              onPressed: fun,
              child: Text(
                text[i],
                style: TextStyle(fontSize: 15.0, color: c),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              borderSide: BorderSide(color: c, width: 3.0),
            ),
          ),
        ),
      );
    }

    return children;
  }

}
