import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutUs extends StatefulWidget {
  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  static const platform = const MethodChannel('com.az.quiz/intent');
  @override
  Widget build(BuildContext context) {
    TextStyle _header = TextStyle(fontWeight: FontWeight.bold, fontSize: 20);

    TextStyle _body = TextStyle(fontSize: 17);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200.withOpacity(0.1),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 200,
                alignment: Alignment.center,
                child: Image.asset(
                  'images/sole_logo.png',
                  height: 150.0,
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                // alignment: Alignment.center,
                child: Text(
                  'SOCIETY OF LITERARY ENTHUSIASTS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Text(
                'Sankalp Rath',
                style: _header,
              ),
              Text(
                '(Literary Secretary)',
                style: _body,
              ),
              SizedBox(
                height: 50,
              ),
              Text(
                'Shubhrashree Lopamudra Dash',
                style: _header,
              ),
              Text(
                '(Asst. Literary Secretary)',
                style: _body,
              ),
              SizedBox(
                height: 50,
              ),
              Text(
                'Ankit Mohanty',
                style: _header,
              ),
              Text(
                'Madhusmita',
                style: _header,
              ),
              Text(
                '(Literary Representatives)',
                style: _body,
              ),
              SizedBox(
                height: 50,
              ),
              Text(
                'Md.Azharuddin',
                style: _header,
              ),
              Text(
                '(App developer)',
                style: _body,
              ),
              SizedBox(
                height: 50,
              ),
              Text(
                'Follow us on',
                style: _header,
              ),
              GestureDetector(
                child: Image.asset(
                  'images/facebook.png',
                  height: 70,
                ),
                onTap: () {
                  try {
                    platform.invokeMethod('facebookIntent');
                  } catch (e) {
                    print("Failed to load: $e");
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('Please try again.'),
                    ));
                  }
                },
              ),
              Text(
                'For any Query',
                style: _header,
              ),
              IconButton(
                icon: Icon(Icons.call),
                iconSize: 40,
                onPressed: () {
                  try {
                    platform.invokeMethod('callIntent');
                  } catch (e) {
                    print("Failed to call: $e");
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('Please try again.'),
                    ));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
