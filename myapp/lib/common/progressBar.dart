import 'package:flutter/material.dart';

class ProgressBar extends StatefulWidget {
  ProgressBar({Key key}) : super(key: key);

  @override
  ProgressBarState createState() => ProgressBarState();
}

class ProgressBarState extends State<ProgressBar> {
  double _position = 0;

  void updatePosition(Duration position, Duration totalDuration) {
    setState(() {
      _position = position.inMilliseconds / totalDuration.inMilliseconds * 100;
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Container(
      height: height / 10 - 60,
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Slider(
        min: 0,
        max: 100,
        value: _position,
        onChanged: null, 
      ),
    );
  }
}
