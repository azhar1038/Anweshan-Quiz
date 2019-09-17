import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';

import 'package:quiz/pages/error.dart';

class TopBar extends StatelessWidget implements PreferredSize{
  final String title;
  final Widget active;

  @override
  final Size preferredSize;

  TopBar({
    @required this.title,
    @required this.active
  }) : preferredSize = Size.fromHeight(60.0); // Height of TopBar is set here.

  @override
  Widget get child => active;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Card(
            child: Container(
              height: 50,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: StreamBuilder(
                    stream: Connectivity().onConnectivityChanged,
                    builder: (BuildContext context, AsyncSnapshot<ConnectivityResult> snapshot){
                      if(!snapshot.hasData){
                        return FutureBuilder(
                          future: Connectivity().checkConnectivity(),
                          builder: (context, snapshot){
                            if(snapshot.connectionState == ConnectionState.done){
                              if(snapshot.hasError) return Error(error:'Oops! There was some error loading your data.');
                              return getDisplayIcon(snapshot.data);
                            }
                            else return Icon(Icons.lightbulb_outline, color: Colors.yellow);
                          },
                        );
                      }
                      var result = snapshot.data;
                      return getDisplayIcon(result);
                    },
                  ),
                ),
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(topRight: Radius.circular(30))
            ),
            elevation: 10,
          ),

          Card(
            child: Container(
              width: MediaQuery.of(context).size.width/1.5,
              height: 50,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 30),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30)),
            ),
            elevation: 10,
          ),
        ],
      ),
    );
  }
  Widget getDisplayIcon(ConnectivityResult result){
    switch(result){
      case ConnectivityResult.none:
        print('NO INTERNET');
        return Icon(Icons.error_outline, color: Colors.red);
      case ConnectivityResult.mobile:
      case ConnectivityResult.wifi:
        print('CONNECTED');
        return active;
      default:
        return Icon(Icons.lightbulb_outline, color: Colors.yellow);
    }
  }
}