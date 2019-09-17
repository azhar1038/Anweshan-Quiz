import 'package:flutter/material.dart';

class Countdown extends StatelessWidget {
  final AnimationController controller;
  final Animation<double> width;
  final Animation color1;
  final Animation color2;
  final double height;

  Countdown({Key key, @required this.controller, @required this.height})
      : width = Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).animate(controller),
        color1 = ColorTween(begin: Colors.green, end: Colors.amber, ).animate(
            CurvedAnimation(parent: controller, curve: Interval(0.0, 0.4))),
        color2 = ColorTween(begin: Colors.amber, end: Colors.red).animate(
            CurvedAnimation(parent: controller, curve: Interval(0.6, 1.0))),
        super(key: key);

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Container(
      width: width.value * MediaQuery.of(context).size.width,
      height: height,
      child: child,
      decoration: BoxDecoration(
        color: width.value>0.5?color1.value:color2.value,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: _buildAnimation,
      animation: controller,
    );
  }
}
