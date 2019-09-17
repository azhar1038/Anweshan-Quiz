import 'package:flutter/material.dart';

class Wait extends StatelessWidget {

  final String waitText;

  Wait({
    @required this.waitText,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.lightBlue[200], Colors.lightBlue[100], Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(bottom: 30.0),
                child: CircularProgressIndicator()
              ),
              Text(waitText),
            ],
          ),
        ),
      ),
    );
  }
}