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

  static const platform = const MethodChannel('com.az.quiz/intent');
  AnimationController controllerInvite, controllerDaily, controllerTournament;
  bool _buttonReady;

  @override
  void initState() {
    super.initState();
    _buttonReady = true;
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
      mainAxisAlignment: MainAxisAlignment.start,
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
    if (_buttonReady) {
      _buttonReady = false;
      GoogleAuth auth = GoogleAuth();
      String email = (await auth.getUser()).email;
      ReferralHelper().generateReferralLink(email).then((Uri referralLink) {
        var message =
            'I found this interesting app! Check it out.\n$referralLink';
        try {
          platform.invokeMethod('referralIntent', message);
        } catch (e) {
          print("Failed to reffer: $e");
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Failed to generate Invitation.'),
          ));
        } finally {
          _buttonReady = true;
          controllerInvite.reverse();
        }
      }).catchError((error){
        print(error.cause);
        showSnackbar('Failed to generate link. Try again.');
        _buttonReady=true;
        controllerInvite.reverse();
      }).timeout(Duration(seconds: 5), onTimeout: () {
        _buttonReady = true;
        controllerInvite.reverse();
        showSnackbar('Oops! Try again.');
      });
    } else {
      await Future.delayed(Duration(milliseconds: 100));
      controllerInvite.reverse();
      showSnackbar('Please wait.');
    }
  }

  startDailyChallenge() async {
    if (_buttonReady) {
      _buttonReady = false;
      FirestoreHelper().getUserDetails(email).then((user) {
        int prevDay = user['dailyChallengeDay'];
        int prevMonth = user['dailyChallengeMonth'];
        int prevYear = user['dailyChallengeYear'];
        controllerDaily.reverse();
        _buttonReady = true;
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
        _buttonReady = true;
      }).timeout(Duration(seconds: 5), onTimeout: () {
        _buttonReady = true;
        controllerDaily.reverse();
        showSnackbar('Oops! Try again.');
      });
    } else {
      await Future.delayed(Duration(milliseconds: 100));
      controllerDaily.reverse();
      showSnackbar('Please wait.');
    }
  }

  startTournament() async {
    if (_buttonReady) {
      _buttonReady = false;
      FirestoreHelper().getUserDetails(email).then((user) {
        _buttonReady = true;
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
        _buttonReady = true;
        controllerTournament.reverse();
      }).timeout(Duration(seconds: 5), onTimeout: (){
        _buttonReady = true;
        controllerTournament.reverse();
        showSnackbar('Oops! Try again.');
      });
    } else {
      await Future.delayed(Duration(milliseconds: 100));
      controllerTournament.reverse();
      showSnackbar('Please wait.');
    }
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
