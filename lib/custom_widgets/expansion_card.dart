import 'package:flutter/material.dart';

class ExpansionCard extends StatefulWidget {
  final Widget header;
  final Widget body;
  final Duration duration;
  final double initialElevation;
  final double finalElevation;
  final bool descriptionFadeIn;

  ExpansionCard({
    @required this.header,
    @required this.body,
    this.duration = const Duration(milliseconds: 500),
    this.initialElevation = 3,
    this.finalElevation = 10,
    this.descriptionFadeIn = true,
  });

  @override
  _ExpansionCardState createState() => _ExpansionCardState();
}

class _ExpansionCardState extends State<ExpansionCard>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _elevation, _height, _opacity;

  @override
  void initState() {
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _elevation = Tween<double>(
      begin: widget.initialElevation,
      end: widget.finalElevation,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.4, 0.7, curve: Curves.ease),
      ),
    );
    _height = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.ease,
      ),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.all(16.0),
      child: AnimatedBuilder(
        animation: _elevation,
        builder: (context, child) {
          return Material(
            elevation: _elevation.value,
            color: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: InkWell(
              onTap: () {
                if (_controller.status == AnimationStatus.completed)
                  _controller.reverse();
                else
                  _controller.forward();
                setState(() {});
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  widget.header,
                  SizeTransition(
                    axisAlignment: 1.0,
                    sizeFactor: _height,
                    child: Container(
                      child: Opacity(
                        opacity: _opacity.value,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Divider(),
                            widget.body,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
