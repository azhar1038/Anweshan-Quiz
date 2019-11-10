import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'utils/authentication.dart';
import 'pages/tabs.dart';
import 'pages/sign_in.dart';
import 'pages/error.dart';
import 'pages/wait.dart';

void main(){
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark
    )
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_){
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      debugShowCheckedModeBanner: false,
      title: 'Quiz',
      home: Homepage()
    );
  }
}

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.subscribeToTopic('all');
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> notification) async {
        print(notification.toString());
        return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context){
            return AlertDialog(
              title: Text(notification['notification']['title']??''),
              content: Text(notification['notification']['body']??''),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  textColor: Colors.green,
                  onPressed: ()=>Navigator.of(context).pop(),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return homePage();
  }

  Widget homePage(){
    GoogleAuth auth = new GoogleAuth();
    return FutureBuilder(
      future: auth.getUser(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if(snapshot.connectionState == ConnectionState.done){
          if(snapshot.hasError) return Error(error: 'Oops! Failed to get User details! Restart and try again.',);
          if(snapshot.data != null){
            Map<String, dynamic> user ={
              'email':snapshot.data.email,
              'name':snapshot.data.displayName,
              'photoUrl':snapshot.data.photoUrl,
            };
            return Tabs(user: user);
          } else {
            return SignIn();
          }
        } else {
          return Wait(waitText: 'Loading...',);
        }
      },
    );
  }
}