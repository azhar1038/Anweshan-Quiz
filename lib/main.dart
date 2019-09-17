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
      home: homePage()
    );
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