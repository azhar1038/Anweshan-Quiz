import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:quiz/pages/registration.dart';

class AnweshanCurrent extends StatefulWidget {
  final Map<String, dynamic> user;

  AnweshanCurrent({@required this.user});

  @override
  _AnweshanCurrentState createState() => _AnweshanCurrentState();
}

class _AnweshanCurrentState extends State<AnweshanCurrent> {
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
                        onPressed: () {},
                      ),
                    ),
                  ),
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
                          'Registration',
                        ),
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  Registration(user: widget.user),
                            ),
                          );
                        },
                      ),
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
}
