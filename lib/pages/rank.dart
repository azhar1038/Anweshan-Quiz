import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quiz/pages/wait.dart';

class Rank extends StatefulWidget {
  @override
  _RankState createState() => _RankState();
}

class _RankState extends State<Rank> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder(
        future: getRankers(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Text('Oops! There was some error loading the data.');
            }
            return displayRankers(snapshot.data);
          }
          return Wait(
            waitText: 'Please wait while we load Data.',
          );
        },
      ),
    );
  }

  Future<QuerySnapshot> getRankers() async {
    QuerySnapshot score = await Firestore.instance
        .collection('users')
        .orderBy('tournamentScore', descending: true)
        .limit(5)
        .getDocuments();
    return score;
  }

  Widget displayRankers(QuerySnapshot data) {
    List<DocumentSnapshot> score = data.documents;
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 10.0),
          padding: EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: Text(
            'Tournament Leaderboard',
            style: TextStyle(
              fontSize: 23.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ScrollConfiguration(
            behavior: MyScrollBehaviour(),
            child: ListView.builder(
              itemCount: score.length,
              itemBuilder: (BuildContext context, int index) {
                Color background;
                if (index == 0)
                  background = Color(0xffffd700);
                else if (index == 1)
                  background = Color(0xffc0c0c0);
                else if (index == 2)
                  background = Color(0xffc49c48);
                else
                  background = Colors.transparent;
                String name = score[index].data['name'].toString();
                String answers =
                    score[index].data['tournamentScore'].toString();
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: background,
                    foregroundColor: Colors.black,
                    child: Text(
                      (index + 1).toString(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(name),
                  subtitle: Text('Total Score: $answers'),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class MyScrollBehaviour extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
