import 'dart:async';
import 'package:flutter/material.dart';

class ElapsedTime {
  final int hundreds;
  final int seconds;
  final int minutes;

  ElapsedTime({this.hundreds, this.seconds, this.minutes});
}

class ConfigTimer {
  final List<ValueChanged<ElapsedTime>> timeListeners =
      <ValueChanged<ElapsedTime>>[];
  final Stopwatch stopwatch = Stopwatch();
  final int refreshRateMilliseconds = 30;
}

class TimerContent extends StatefulWidget {
  TimerContent({Key key}) : super(key: key);

  @override
  TimerContentState createState() => TimerContentState();
}

class TimerContentState extends State<TimerContent> {
  final ConfigTimer config = ConfigTimer();

  void start() {
    if (!config.stopwatch.isRunning) config.stopwatch.start();
  }

  void stop() {
    if (config.stopwatch.isRunning) config.stopwatch.stop();
  }

  void reset() {
    config.stopwatch.reset();
  }

  @override
  Widget build(BuildContext context) {
    return TimerText(config: config);
  }
}

class TimerText extends StatefulWidget {
  TimerText({this.config});
  final ConfigTimer config;

  @override
  _TimerTextState createState() => _TimerTextState(config: config);
}

class _TimerTextState extends State<TimerText> {
  _TimerTextState({this.config});
  final ConfigTimer config;
  Timer timer;
  int milliseconds;

  @override
  void initState() {
    timer = Timer.periodic(
        Duration(milliseconds: config.refreshRateMilliseconds), callback);
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  void callback(Timer timer) {
    if (milliseconds != config.stopwatch.elapsedMilliseconds) {
      milliseconds = config.stopwatch.elapsedMilliseconds;
      final int hundreds = (milliseconds / 10).truncate();
      final int seconds = (hundreds / 100).truncate();
      final int minutes = (seconds / 60).truncate();
      final ElapsedTime elapsedTime =
          ElapsedTime(hundreds: hundreds, seconds: seconds, minutes: minutes);
      for (final listener in config.timeListeners) {
        listener(elapsedTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RepaintBoundary(
          child: SizedBox(
            child: MinutesAndSeconds(config: config),
          ),
        ),
        RepaintBoundary(
          child: SizedBox(
            child: Hundreds(config: config),
          ),
        )
      ],
    );
  }
}

class MinutesAndSeconds extends StatefulWidget {
  MinutesAndSeconds({this.config});
  final ConfigTimer config;

  @override
  _MinutesAndSecondsState createState() =>
      _MinutesAndSecondsState(config: config);
}

class _MinutesAndSecondsState extends State<MinutesAndSeconds> {
  _MinutesAndSecondsState({this.config});
  final ConfigTimer config;

  int minutes = 0;
  int seconds = 0;

  @override
  void initState() {
    config.timeListeners.add(_actualizeTime);
    super.initState();
  }

  void _actualizeTime(ElapsedTime elapsedTime) {
    if (elapsedTime.minutes != minutes || elapsedTime.seconds != seconds) {
      setState(() {
        minutes = elapsedTime.minutes;
        seconds = elapsedTime.seconds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    TextStyle timerStyle = TextStyle(fontSize: 60.0, color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : Colors.grey );
    return Text('$minutesStr:$secondsStr.', style: timerStyle);
  }
}

class Hundreds extends StatefulWidget {
  Hundreds({this.config});
  final ConfigTimer config;

  @override
  _HundredsState createState() => _HundredsState(config: config);
}

class _HundredsState extends State<Hundreds> {
  _HundredsState({this.config});
  final ConfigTimer config;

  int hundreds = 0;

  @override
  void initState() {
    config.timeListeners.add(_actualizeTime);
    super.initState();
  }

  void _actualizeTime(ElapsedTime elapsedTime) {
    if (elapsedTime.hundreds != hundreds) {
      setState(() {
        hundreds = elapsedTime.hundreds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String hundredsStr = (hundreds % 100).toString().padLeft(2, '0');
    TextStyle timerStyle = TextStyle(fontSize: 60.0, color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : Colors.grey );
    return Text(hundredsStr, style: timerStyle);
  }
}
