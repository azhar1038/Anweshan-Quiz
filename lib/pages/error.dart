import 'package:flutter/material.dart';

class Error extends StatelessWidget {

  final String error;

  Error({
    @required this.error,
  }):assert(error != ' ');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(error),),
    );
  }
}