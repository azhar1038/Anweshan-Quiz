import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:quiz/custom_widgets/expansion_card.dart';

import '../custom_widgets/top_bar.dart';
import 'user_profile.dart';

class Event {
  String title, day, description;
  List<String> coordinators, professors;

  Event({
    @required this.title,
    @required this.description,
    this.day,
    this.coordinators,
    this.professors,
  });
}

class Anweshan2020 extends StatefulWidget {
  final Map<String, dynamic> user;

  Anweshan2020({
    @required this.user,
  });
  @override
  _Anweshan2020State createState() => _Anweshan2020State();
}

class _Anweshan2020State extends State<Anweshan2020> {
  List<Event> events = List<Event>();

  @override
  void initState() {
    events.add(Event(
      title: 'Spell Bee',
      description:
          'Ever pictured yourself on the apex podium in the realm of enthralling BEES battling for perfection in English Vocabulary & Spelling? It\'s a chance & platform where we check whether/not you have the grit & passion to go the extra mile to develop correct English usage & Spelling. ALL BEES UNITE!',
    ));
    events.add(Event(
      title: 'Parliamentary Debate',
      description:
          'Is CAB the talk of the hour or is delaying the hanging of Nirbhaya convicts, the major issue? What are your stance on burning issues across today\'s India? Need a platform to speak your mind out? Well worry no more, cause this Anweshan, we bring you Parliamentary Debate for all the fire within you to be ignited into debating.',
    ));
    events.add(Event(
      title: 'JAM',
      description:
          'Just A Minute is all you get to speak your mind and heart out, but dare not commit a mistake or you\'ll be jammed out! What a mere minutely important minute huh? So can you stand out for the maximum seconds and be the battle field hero or will you be jammed too? Stay tuned to Anweshan 2k20 to find out.',
    ));
    events.add(Event(
      title: 'Group Discussion',
      description: "We've all got opinions, and like our fingers varying morphologically, every one of our thoughts vary. We all talk with our friends, but what if we make our talk a bit more productive by voicing our opinions into discussions? Don't worry, we've got the right platform for you and your friends this Anweshan with Group Discussions on board.",
    ));
    events.add(Event(
      title: 'Quiz',
      description: "Are you someone who is inherently curious about the life history of great rulers, or records set by sports players, or etymology of words or unusual shape of Cyprus? Do you wonder about everything under the sun?\n\nIf trivia excited you, it doesn't matter if your intellect lies in tech or prowess in business. It doesn't matter if you're a generalist or a specialist. We've a place for you all in this Anweshan. Don't miss the chance to get your brain buzzing with the satisfaction of decoding a good question.\n\nQuiz and let quiz!",
    ));
    events.add(Event(
      title: 'Danger word',
      description: "Just as it sounds, danger word involves two membered teams of two, where in each team one guesses and one gives single worded clue. Two words are given, out of which one is the safe word and the other the danger word. The guessing partner has to guess the safe word and NOT say the danger word. The partner giving clues has to ensure that clues are framed in such a way that guessing partner doesn't say the danger word, else they lose.",
    ));
    events.add(Event(
      title: 'Creative writing',
      description: "This is for the people who find themselves spinning stories while sitting idle, who get a spurt of inspiration in the middle of a serious conversation and rush to write that down. This is for the people whose pens do not stop even when the ink dries. This is for the people who can alter reality, or create one, just using their mind. This is for the paper superheroes, who believe that the pen is mightier that the sword. Anweshan 2020 welcomes all of you to this event with the freedom to make full use of your superpower.",
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Image.asset(
          'images/background.jpg',
          fit: BoxFit.cover,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.bottomCenter,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: TopBar(
            title: 'Anweshan2020',
            active: GestureDetector(
              child: avatar(),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => UserProfile(user: widget.user),
                ),
              ),
            ),
          ),
          body: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: Colors.grey.shade200.withOpacity(0.1),
              ),
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return ExpansionCard(
                    header: Container(
                      padding: EdgeInsets.all(16.0),
                      alignment: Alignment.center,
                      child: Text(
                        events[index].title,
                        style: Theme.of(context).textTheme.title,
                      ),
                    ),
                    body: Container(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          events[index].day != null?Padding(
                            padding: const EdgeInsets.only(bottom:8.0),
                            child: Text(
                              events[index].day,
                              style: Theme.of(context)
                                  .textTheme
                                  .subhead
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                          ):Container(),
                          Text(
                            events[index].description,
                            textAlign: TextAlign.justify,
                          ),
                          events[index].coordinators != null?Text(
                            'Coordinators: ',
                            style: Theme.of(context)
                                .textTheme
                                .subhead
                                .copyWith(fontWeight: FontWeight.w700),
                          ):Container(),
                          events[index].coordinators != null?Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ListView.builder(
                              itemCount: events[index].coordinators.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, i) {
                                return Text(events[index].coordinators[i]);
                              },
                            ),
                          ):Container(),
                          events[index].professors != null
                              ? Text(
                                  'Professors: ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .subhead
                                      .copyWith(fontWeight: FontWeight.w700),
                                )
                              : Container(),
                          events[index].professors != null
                              ? ListView.builder(
                                  itemCount: events[index].professors.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, i) {
                                    return Text(events[index].professors[i]);
                                  },
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget avatar() {
    double radius = 12.0;
    if (widget.user['photoUrl'] != null)
      return CircleAvatar(
        backgroundImage: NetworkImage(widget.user['photoUrl']),
        radius: radius,
      );
    else
      return CircleAvatar(
        backgroundColor: Colors.green,
        child: Text(widget.user['name'][0]),
        radius: radius,
      );
  }
}
