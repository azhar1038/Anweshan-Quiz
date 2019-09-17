import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';

class WaitButton extends StatefulWidget {
  final AnimationController controller;
  final double width;
  final double height;
  final Color color;
  final Widget child;
  final VoidCallback onPressed;

  WaitButton({
    Key key,
    @required this.controller,
    @required this.child,
    @required this.onPressed,
    this.width = 300.0,
    this.height = 60.0,
    this.color = Colors.purple,
  }):super(key:key);

  @override
  _WaitButtonState createState() => _WaitButtonState(
        controller: controller,
        child: child,
        width: width,
        height: height,
        color: color,
        onPressed: onPressed,
      );
}

class _WaitButtonState extends State<WaitButton> {
  final AnimationController controller;
  final Widget child;
  final Color color;
  final VoidCallback onPressed;
  double width;
  double height;
  Animation<double> animation;

  _WaitButtonState({
    @required this.controller,
    @required this.child,
    @required this.onPressed,
    this.color,
    this.width,
    this.height,
  });

  @override
  void initState() {
    super.initState();
    animation = Tween<double>(
      begin: width,
      end: height,
    ).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeIn),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTap: () {
            if (animation.value == width) {
              print('Tapped');
              onPressed();
              controller.forward();
            }
          },
          child: AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget child) {
              return Container(
                margin: EdgeInsets.all(8.0),
                height: height,
                width: animation.value,
                alignment: Alignment.center,
                child: animation.value > 100.0
                    ? child
                    : SizedBox(
                        height: height - 15,
                        width: height - 15,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 2.0,
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(height/2),
                        color: color,
                      ),
              );
            },
            child: child,
          ),
        );

  }

  wait() async {
    Future.delayed(Duration(seconds: 3)).then((_) {
      controller.reverse();
    });
  }
}
