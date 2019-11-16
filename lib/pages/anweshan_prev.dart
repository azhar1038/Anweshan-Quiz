import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:quiz/custom_widgets/expansion_card.dart';

class Event {
  String title, day;
  List<String> coordinators, professors;

  Event({
    @required this.title,
    @required this.day,
    @required this.coordinators,
    this.professors,
  });
}

class AnweshanPrev extends StatefulWidget {
  @override
  _AnweshanPrevState createState() => _AnweshanPrevState();
}

class _AnweshanPrevState extends State<AnweshanPrev> {
  List<Event> events = List<Event>();

  @override
  void initState() {
    events.add(Event(
      title: 'Creative Writing',
      day: '6 March, Wednesday',
      coordinators: ['Priya', 'Prateek'],
      professors: ['Prof. Dr. Maheshwar Maharana', 'Prof. Dr. S.N. Mishra'],
    ));
    events.add(Event(
      title: 'Aptitude Test',
      day: '6 March, Wednesday',
      coordinators: ['Sidhant', 'Swagat'],
      professors: ['Prof. P.R. Dhal', 'Prof. Anup Swain'],
    ));
    events.add(Event(
      title: 'Yourquote Openmic',
      day: '7 March, Thursday',
      coordinators: ['Lopamudra', 'Dheeraj', 'Swagat'],
    ));
    events.add(Event(
      title: 'Rangoli',
      day: '8 March, Friday',
      coordinators: ['Priya', 'Siddhant', 'Siddhart'],
      professors: ['Prof. Jully Randhari', 'Prof. Supriya Behera'],
    ));
    events.add(Event(
      title: 'Game of Audios',
      day: '8 March, Friday',
      coordinators: ['Sambit', 'Prateek'],
    ));
    events.add(Event(
      title: 'Group Discussion',
      day: '9 March, Saturday',
      coordinators: ['Abhisekh', 'Lalit', 'Dheeraj', 'Payal'],
      professors: ['Prof. Siddharth Tiwari', 'Prof. Rao'],
    ));
    events.add(Event(
      title: 'Final Year Workshop',
      day: '9 March, Saturday',
      coordinators: ['Lopamudra', 'Prateek'],
    ));
    events.add(Event(
      title: 'Literary Workshop',
      day: '10 March, Sunday',
      coordinators: ['Payal', 'Lalit'],
    ));
    events.add(Event(
      title: 'Water Colour Painting',
      day: '11 March, Monday',
      coordinators: ['Priya', 'Lopamudra'],
      professors: ['Prof. Krishnakol Dutta', 'Prof. Shilpi Chakraborty'],
    ));
    events.add(Event(
      title: 'Face Painting',
      day: '11 March, Monday',
      coordinators: ['Aspita', 'Lopamudra'],
    ));
    events.add(Event(
      title: 'Debate',
      day: '12 March, Tuesday',
      coordinators: ['Dheeraj', 'Ananya'],
      professors: ['Prof. K.D. Sa', 'Prof. Dr. Pranati Das'],
    ));
    events.add(Event(
        title: 'Salt Painting',
        day: '12 March, Tuesday',
        coordinators: ['Dheeraj', 'Payal'],
        professors: ['Prof. Shilpi Chakraborty', 'Prof. Abinash Pujari']));
    events.add(Event(
      title: 'JAM',
      day: '13 March, Wednesday',
      coordinators: ['Swagat', 'Sidhant'],
      professors: ['Prof. Paresh Ku. Passayat', 'Prof. Kasinath Barik'],
    ));
    events.add(Event(
      title: 'Ad-Mad',
      day: '13 March, Wednesday',
      coordinators: ['Sambit', 'Priya'],
      professors: ['Prof. Prateek Mishra', 'Prof. Prateek Acharya'],
    ));

    super.initState();
  }

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
                    Text(
                      events[index].day,
                      style: Theme.of(context)
                          .textTheme
                          .subhead
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Coordinators: ',
                      style: Theme.of(context)
                          .textTheme
                          .subhead
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    ListView.builder(
                      itemCount: events[index].coordinators.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, i) {
                        return Text(events[index].coordinators[i]);
                      },
                    ),
                    SizedBox(height: 10),
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
    );
  }
}
