import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myapp/common/circularBtn3d.dart';
import 'package:myapp/common/dialog.dart';
import 'package:myapp/common/progressBar.dart';
import 'package:myapp/common/timer.dart';
import 'package:myapp/utils/cache.dart';
import 'package:audio_recorder/audio_recorder.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:myapp/utils/recordInfo.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class RecorderPage extends StatefulWidget {
  @override
  _RecorderPageState createState() => _RecorderPageState();
}

class _RecorderPageState extends State<RecorderPage>
    with TickerProviderStateMixin {
  final AudioPlayer audioPlayer = AudioPlayer();
  RecordInfo _info = RecordInfo();
  Color color;
  List<Widget> recordingAction = [];
  List<Widget> saveAction = [];
  AllDialog _dialog = AllDialog();
  AnimationController _fadeController;
  AnimationController _bouncyController;
  Animation _animation;

  final GlobalKey<ProgressBarState> progressBar = GlobalKey<ProgressBarState>();

  @override
  void initState() {
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
      reverseDuration: Duration(milliseconds: 800),
    );
    _bouncyController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
      reverseDuration: Duration(milliseconds: 800),
      value: 0.1,
    );
    _animation = CurvedAnimation(
      parent: _bouncyController,
      curve: Curves.bounceOut,
      reverseCurve: Curves.easeOut,
    );
    AudioRecorder.isRecording.then((stateRecording) {
      setState(() {
        _info.setIsRecording(stateRecording);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var timerService = TimerService.of(context);
    Color _setColorBoxShadow() {
      return (Theme.of(context).brightness == Brightness.dark)
          ? Colors.white.withOpacity(0.05) // black background
          : Colors.white.withOpacity(1); // white background
    }

    color = (Theme.of(context).brightness == Brightness.light)
        ? Colors.black
        : Colors.white;

    recordingAction.clear();
    recordingAction.addAll(
      [
        Container(
          child: AnimatedBuilder(
            animation: timerService,
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TimerDisplay(duration: timerService.currentDuration),
                ],
              );
            },
          ),
          padding: EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).scaffoldBackgroundColor,
            shape: BoxShape.rectangle,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: Offset.fromDirection(3.8, 2),
                  blurRadius: 2.0,
                  spreadRadius: 0.0),
              BoxShadow(
                  color: _setColorBoxShadow(),
                  offset: Offset.fromDirection(.8, 2),
                  blurRadius: 2.0,
                  spreadRadius: 0.0),
            ],
          ),
        ),
        PrimaryCircularBtn3d(
          _selectIcon(),
          (height - 60) / 4,
          Theme.of(context).scaffoldBackgroundColor,
          () {
            _selectFunction(timerService);
          },
        ),
        FadeTransition(
          opacity: _fadeController,
          child: Container(
            padding: const EdgeInsets.only(top: 30, bottom: 0.0),
            child: ProgressBar(key: progressBar),
          ),
        ),
      ],
    );

    saveAction.clear();
    saveAction.addAll(
      [
        ScaleTransition(
          scale: _animation,
          alignment: Alignment.center,
          child: FadeTransition(
            opacity: _fadeController,
            child: SecondaryCircularBtn3d(
              Icon(
                Icons.save,
                color: color,
                size: (height - 60) / 10 - 30,
              ),
              (height - 60) / 10,
              Theme.of(context).scaffoldBackgroundColor,
              () {
                _dialog.callMonoInputDialog(
                  context,
                  'Insert name:',
                  _info.recordPath(),
                  (data) {
                    _saveRecord(data, timerService);
                  },
                );
              },
            ),
          ),
        ),
        ScaleTransition(
          scale: _animation,
          alignment: Alignment.center,
          child: FadeTransition(
            opacity: _fadeController,
            child: SecondaryCircularBtn3d(
              Icon(
                Icons.delete,
                color: color,
                size: (height - 60) / 10 - 30,
              ),
              (height - 60) / 10,
              Theme.of(context).scaffoldBackgroundColor,
              () {
                _deleteRecord(timerService);
              },
            ),
          ),
        ),
      ],
    );

    return ListView(
      children: [
        Container(
          padding: EdgeInsets.only(top: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: recordingAction,
          ),
        ),
        Container(
          padding: EdgeInsets.only(bottom: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: saveAction,
          ),
        ),
      ],
    );
  }

  _selectIcon() {
    if (!_info.isRecording() && _info.recordPath() == null) {
      return Icon(
        Icons.fiber_manual_record,
        color: Colors.redAccent,
        size: 80,
      );
    } else if (_info.isRecording()) {
      return SpinKitDoubleBounce(
        color: Colors.redAccent,
        size: 175,
      );
    } else if (!_info.isRecording() &&
        _info.recordPath() != null &&
        !_info.isPlaying()) {
      _fadeController.forward();
      _bouncyController.forward();
      return Icon(
        Icons.play_arrow,
        color: color,
        size: 80,
      );
    } else if (!_info.isRecording() &&
        _info.recordPath() != null &&
        _info.isPlaying()) {
      return Icon(
        Icons.stop,
        color: color,
        size: 80,
      );
    }
  }

  _selectFunction(timerService) {
    if (!_info.isRecording() && _info.recordPath() == null) {
      if (!_info.isRecording()) _startRecord(timerService);
    } else if (_info.isRecording()) {
      if (_info.isRecording()) _stopRecord(timerService);
    } else if (!_info.isRecording() &&
        _info.recordPath() != null &&
        !_info.isPlaying()) {
      _playRecord();
    } else if (!_info.isRecording() &&
        _info.recordPath() != null &&
        _info.isPlaying()) {
      _stopPlaying();
    }
  }

  // RECORDING FUNCTION
  _startRecord(var timerService) async {
    PermissionStatus microPermission;
    if (Platform.isIOS) {
      await PermissionHandler()
          .requestPermissions([PermissionGroup.microphone]);
    } else {
      await PermissionHandler().requestPermissions(
          [PermissionGroup.microphone, PermissionGroup.storage]);
    }
    microPermission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.microphone);
    if (Platform.isIOS && microPermission != PermissionStatus.granted) {
      _dialog.callInfoDialog(context, 'ACCESS PERMISSION',
          'Please give me your permissions to record and save 🙏', () async {
        await PermissionHandler().openAppSettings();
      });
    }
    try {
      if (await AudioRecorder.hasPermissions && !_info.isRecording()) {
        setState(() {
          _info.setIsRecording(true);
        });
        timerService.start();
        await AudioRecorder.start();
        await AudioRecorder.isRecording;
      }
    } catch (e) {
      setState(() {
        _info.setIsRecording(false);
      });
    }
  }

  _stopRecord(var timerService) async {
    if (_info.isRecording()) {
      try {
        timerService.stop();
        await Future.delayed(Duration(milliseconds: 300));
        var recording = await AudioRecorder.stop();
        setState(() {
          _info.setIsRecording(false);
          _info.setRecordPath(recording.path);
          _info.setDuration(recording.duration);
        });
      } catch (e) {}
    }
  }

  // PLAYING FUNCTION
  _playRecord() async {
    audioPlayer.onPlayerCompletion.listen((stop) {
      this
          .progressBar
          .currentState
          .updatePosition(_info.getDuration(), _info.getDuration());
      setState(() {
        _info.setIsPlaying(false);
      });
    });
    audioPlayer.onAudioPositionChanged.listen((position) {
      this
          .progressBar
          .currentState
          .updatePosition(position, _info.getDuration());
    });
    setState(() {
      _info.setIsPlaying(true);
    });
    await audioPlayer.play(_info.recordPath(), isLocal: true);
  }

  _stopPlaying() async {
    setState(() {
      _info.setIsPlaying(false);
    });
    await audioPlayer.stop();
  }

  // SAVE / DELETE RECORDING
  _saveRecord(String name, var timerService) {
    Cache _cache = Cache();
    _triggerSnackBar('Saved', Icons.check);
    _cache.saveRecord(
        (name.length > 0) ? name : _info.recordPath(), _info.recordPath());
    timerService.reset();
    setState(() {
      _fadeController.reverse();
      _bouncyController.reverse();
      _info.setRecordPath(null);
    });
  }

  _deleteRecord(var timerService) {
    _stopPlaying();
    _dialog.callInfoDialog(context, 'Are you sure ?', '', () {
      _triggerSnackBar('Removed', Icons.clear);
      File(_info.recordPath()).delete();
      timerService.reset();
      setState(() {
        _fadeController.reverse();
        _bouncyController.reverse();
        _info.setRecordPath(null);
      });
    });
  }

  _triggerSnackBar(String text, IconData icon) {
    return Scaffold.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        duration: Duration(seconds: 2),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(icon),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
