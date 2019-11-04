import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiz/utils/authentication.dart';
import 'package:quiz/utils/referral_helper.dart';
import 'package:quiz/pages/daily_challenge.dart';
import 'package:quiz/utils/firestore_helper.dart';
import 'package:quiz/custom_widgets/wait_button.dart';
import 'package:quiz/pages/tournament.dart';

class Home extends StatefulWidget {
  final Map<String, dynamic> user;

  Home({
    @required this.user,
  });

  @override
  _HomeState createState() => _HomeState(email: user['email']);
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final String email;

  _HomeState({
    @required this.email,
  });

  static const platform = const MethodChannel('com.az.quiz/referral');
  AnimationController controllerInvite, controllerDaily, controllerTournament;

  @override
  void initState() {
    super.initState();
    controllerInvite = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    controllerDaily = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    controllerTournament = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          child: WaitButton(
            key: UniqueKey(),
            child: Text(
              'Tournament',
              style: TextStyle(color: Colors.white),
            ),
            controller: controllerTournament,
            color: Colors.lightBlue,
            width: 200.0,
            height: 50.0,
            onPressed: startTournament,
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: WaitButton(
            key: UniqueKey(),
            child: Text(
              'Invite Friends',
              style: TextStyle(color: Colors.white),
            ),
            controller: controllerInvite,
            color: Colors.lightBlue,
            width: 200.0,
            height: 50.0,
            onPressed: sendReferral,
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: WaitButton(
            key: UniqueKey(),
            child: Text(
              'Daily Challenge',
              style: TextStyle(color: Colors.white),
            ),
            controller: controllerDaily,
            color: Colors.lightBlue,
            width: 200.0,
            height: 50.0,
            onPressed: startDailyChallenge,
          ),
        ),
      ],
    );
  }

  sendReferral() async {
    GoogleAuth auth = GoogleAuth();
    String email = (await auth.getUser()).email;
    Uri referralLink = await ReferralHelper().generateReferralLink(email);
    var message = 'I found this interesting app! Check it out.\n$referralLink';
    try {
      platform.invokeMethod('referralIntent', message);
    } catch (e) {
      print("Failed to reffer: $e");
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Failed to generate Invitation.'),
      ));
    } finally {
      controllerInvite.reverse();
    }
  }
  startDailyChallenge() async {
    FirestoreHelper().getUserDetails(email).then((user) {
        int prevDay = user['dailyChallengeDay'];
        int prevMonth = user['dailyChallengeMonth'];
        int prevYear = user['dailyChallengeYear'];
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) {
            return DailyChallenge(
              user: widget.user,
              dailyChallengeDay: prevDay,
              dailyChallengeMonth: prevMonth,
              dailyChallengeYear: prevYear,
              gems: user['gems'],
              now: DateTime.now(),
            );
          }),
        );
    }).catchError((error) {
      print(error.cause);
      showSnackbar('Failed to load User data. Try again.');
      controllerDaily.reverse();
    });
  }

  startTournament() async {
    FirestoreHelper().getUserDetails(email).then((user) {
      controllerTournament.reverse();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return Tournament(
              user: user,
              googleUser: widget.user,
            );
          },
        ),
      );
    }).catchError((error) {
      print(error.cause);
      showSnackbar('Failed to load user data. Try again.');
      controllerTournament.reverse();
    });
  }

  void showSnackbar(String message) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  void dispose() {
    controllerInvite.dispose();
    controllerDaily.dispose();
    controllerTournament.dispose();
    super.dispose();
  }
}
