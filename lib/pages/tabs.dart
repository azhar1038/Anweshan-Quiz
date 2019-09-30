import 'package:flutter/material.dart';

import 'package:quiz/custom_widgets/top_bar.dart';
import 'package:quiz/pages/user_profile.dart';
import 'package:quiz/utils/authentication.dart';
import 'package:quiz/custom_widgets/bottom_nav_bar.dart';
import 'anweshan_prev.dart';
import 'anweshan_current.dart';
import 'home.dart';
import 'rank.dart';
import 'about_us.dart';

GoogleAuth auth = new GoogleAuth();

class Tabs extends StatefulWidget {
  final Map<String, dynamic> user;

  Tabs({
    @required this.user,
  });

  @override
  _TabsState createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  int _selectedIndex;
  PageController _pageController;
  String _title;
  List titles = ['Anweshan 2019', 'Anweshan 2020', 'Home', 'Rank', 'About Us'];
  Color bottomBarColor = Colors.blue;

  @override
  void initState() {
    _selectedIndex = 2;
    _pageController = PageController(initialPage: 2);
    _title = 'Home';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[200],
      appBar: TopBar(
        title: _title,
        active: GestureDetector(
          child: avatar(),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => UserProfile(user: widget.user),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        showElevation: true,
        onItemSelected: (index) {
          if (_selectedIndex != index)
            return setState(() {
              _selectedIndex = index;
              _pageController.jumpToPage(index);
              _title = titles[index];
            });
        },
        items: [
          BottomNavBarItem(
              icon: Text(
                '19',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: bottomBarColor,
                    fontSize: 20),
              ),
              title: Text(
                '2019',
              ),
              activeColor: bottomBarColor),
          BottomNavBarItem(
            icon: Text(
              '20',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: bottomBarColor,
                  fontSize: 20),
            ),
            title: Text(
              '2020',
            ),
            activeColor: bottomBarColor,
          ),
          BottomNavBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
            activeColor: bottomBarColor,
          ),
          BottomNavBarItem(
            icon: Icon(Icons.equalizer),
            title: Text('Rank'),
            activeColor: bottomBarColor,
          ),
          BottomNavBarItem(
              icon: Icon(Icons.group),
              title: Text('About Us'),
              activeColor: bottomBarColor),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.lightBlue[200],
              Colors.lightBlue[100],
              Colors.white
            ],
          ),
        ),
        child: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            AnweshanPrev(),
            AnweshanCurrent(user: widget.user),
            Home(user: widget.user),
            Rank(),
            AboutUs(),
          ],
          onPageChanged: (index) => setState(() {
            _selectedIndex = index;
            _title = titles[index];
          }),
        ),
      ),
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
