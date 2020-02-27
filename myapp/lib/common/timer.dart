import 'dart:async';
import 'package:flutter/material.dart';

class ConfigTimer {
  final Stopwatch stopwatch = Stopwatch();
  final int refreshRateMilliseconds = 30;
}

class TimerDisplay extends StatelessWidget {
  TimerDisplay({this.duration});
  final Duration duration;
  final ConfigTimer config = ConfigTimer();

  @override
  Widget build(BuildContext context) {
    TextStyle timerStyle = TextStyle(
      fontSize: 60.0,
      color: (Theme.of(context).brightness == Brightness.dark)
          ? Colors.white
          : Colors.grey,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RepaintBoundary(
          child: SizedBox(
            width: 70,
            child: _minutes(timerStyle),
          ),
        ),
        Text(
          ':',
          style: timerStyle,
        ),
        RepaintBoundary(
          child: SizedBox(
            width: 70,
            child: _seconds(timerStyle),
          ),
        ),
        Text('.', style: timerStyle),
        RepaintBoundary(
          child: SizedBox(
            child: _hundreds(timerStyle),
            width: 70,
          ),
        )
      ],
    );
  }

  _minutes(TextStyle timerStyle) {
    final int hundreds = (duration.inMilliseconds / 10).truncate();
    final int seconds = (hundreds / 100).truncate();
    final int minutes = (seconds / 60).truncate();
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    return Text(minutesStr, style: timerStyle);
  }

  _seconds(TextStyle timerStyle) {
    final int hundreds = (duration.inMilliseconds / 10).truncate();
    final int seconds = (hundreds / 100).truncate();
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    return Text(secondsStr, style: timerStyle);
  }

  _hundreds(TextStyle timerStyle) {
    final int hundreds = (duration.inMilliseconds / 10).truncate();
    String hundredsStr = (hundreds % 100).toString().padLeft(2, '0');
    return Text(hundredsStr, style: timerStyle);
  }
}

class TimerServiceProvider extends InheritedWidget {
  const TimerServiceProvider({Key key, this.service, Widget child})
      : super(key: key, child: child);

  final TimerService service;

  @override
  bool updateShouldNotify(TimerServiceProvider old) => service != old.service;
}

class TimerService extends ChangeNotifier {
  final ConfigTimer config = ConfigTimer();
  Stopwatch _watch;
  Timer _timer;

  Duration get currentDuration => _currentDuration;
  Duration _currentDuration = Duration.zero;

  bool get isRunning => _timer != null;

  TimerService() {
    _watch = Stopwatch();
  }

  void _onTick(Timer timer) {
    _currentDuration = _watch.elapsed;

    notifyListeners();
  }

  void start() {
    if (_timer != null) return;

    _timer = Timer.periodic(
        Duration(milliseconds: config.refreshRateMilliseconds), _onTick);
    _watch.start();

    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _watch.stop();
    _currentDuration = _watch.elapsed;

    notifyListeners();
  }

  void reset() {
    stop();
    _watch.reset();
    _currentDuration = Duration.zero;

    notifyListeners();
  }

  static TimerService of(BuildContext context) {
    var provider = context.inheritFromWidgetOfExactType(TimerServiceProvider)
        as TimerServiceProvider;
    return provider.service;
  }
}
