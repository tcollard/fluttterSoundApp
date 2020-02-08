import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myapp/common/circularBtn3d.dart';
import 'package:myapp/common/dialog.dart';
import 'package:myapp/common/progressBar.dart';
import 'package:myapp/common/timer.dart';
import 'package:myapp/utils/cache.dart';
import 'package:audio_recorder/audio_recorder.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class RecorderPage extends StatefulWidget {
  @override
  _RecorderPageState createState() => _RecorderPageState();
}

class _RecorderPageState extends State<RecorderPage>
    with TickerProviderStateMixin {
  final AudioPlayer audioPlayer = AudioPlayer();
  Duration _duration;
  bool _isRecording = false;
  bool _isPlaying = false;
  String _recordPath;
  Color color;
  List<Widget> recordingAction = [];
  List<Widget> saveAction = [];
  AllDialog _dialog = AllDialog();
  AnimationController _fadeController;
  AnimationController _bouncyController;
  Animation _animation;

  final GlobalKey<TimerContentState> timerState =
      GlobalKey<TimerContentState>();
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          child: TimerContent(key: timerState),
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
          200,
          Theme.of(context).scaffoldBackgroundColor,
          () {
            _selectFunction();
          },
        ),
        FadeTransition(
          opacity: _fadeController,
          child: Container(
            padding: const EdgeInsets.only(top: 50),
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
                size: 50,
              ),
              90,
              Theme.of(context).scaffoldBackgroundColor,
              () {
                _dialog.callMonoInputDialog(
                  context,
                  'Insert name:',
                  _recordPath,
                  (data) {
                    _saveRecord(data);
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
                size: 50,
              ),
              90,
              Theme.of(context).scaffoldBackgroundColor,
              () {
                _deleteRecord();
              },
            ),
          ),
        ),
      ],
    );

    return ListView(
      children: [
        Container(
          padding: EdgeInsets.only(top: 60.0),
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
    if (!this._isRecording && _recordPath == null) {
      return Icon(
        Icons.fiber_manual_record,
        color: Colors.redAccent,
        size: 80,
      );
    } else if (this._isRecording) {
      return SpinKitDoubleBounce(
        color: Colors.redAccent,
        size: 175,
      );
    } else if (!this._isRecording && _recordPath != null && !this._isPlaying) {
      _fadeController.forward();
      _bouncyController.forward();
      return Icon(
        Icons.play_arrow,
        color: color,
        size: 80,
      );
    } else if (!this._isRecording && _recordPath != null && this._isPlaying) {
      return Icon(
        Icons.stop,
        color: color,
        size: 80,
      );
    }
  }

  _selectFunction() {
    if (!this._isRecording && _recordPath == null) {
      if (!_isRecording) _startRecord();
    } else if (this._isRecording) {
      if (_isRecording) _stopRecord();
    } else if (!this._isRecording && _recordPath != null && !this._isPlaying) {
      _playRecord();
    } else if (!this._isRecording && _recordPath != null && this._isPlaying) {
      _stopPlaying();
    }
  }

  // RECORDING FUNCTION
  _startRecord() async {
    PermissionStatus microPermission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.microphone);
    PermissionStatus storePermission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);

    if (microPermission != PermissionStatus.granted ||
        storePermission != PermissionStatus.granted) {
      _dialog.callInfoDialog(context, 'ACCESS PERMISSION',
          'Please give me your permissions to record and save 🙏', () async {
        await PermissionHandler().openAppSettings();
      });
    }
    try {
      if (await AudioRecorder.hasPermissions && !this._isRecording) {
        setState(() {
          this._isRecording = true;
        });
        this.timerState.currentState.start();
        await AudioRecorder.start();
        await AudioRecorder.isRecording;
      }
    } catch (e) {
      setState(() {
        this._isRecording = false;
      });
    }
  }

  _stopRecord() async {
    if (_isRecording) {
      try {
        this.timerState.currentState.stop();
        await Future.delayed(Duration(milliseconds: 300));
        var recording = await AudioRecorder.stop();
        setState(() {
          this._isRecording = false;
          _recordPath = recording.path;
          _duration = recording.duration;
        });
      } catch (e) {}
    }
  }

  // PLAYING FUNCTION
  _playRecord() async {
    audioPlayer.onPlayerCompletion.listen((stop) {
      this.progressBar.currentState.updatePosition(_duration, _duration);
      setState(() {
        this._isPlaying = false;
      });
    });
    audioPlayer.onAudioPositionChanged.listen((position) {
      this.progressBar.currentState.updatePosition(position, _duration);
    });
    setState(() {
      this._isPlaying = true;
    });
    await audioPlayer.play(_recordPath, isLocal: true);
  }

  _stopPlaying() async {
    setState(() {
      this._isPlaying = false;
    });
    await audioPlayer.stop();
  }

  // SAVE / DELETE RECORDING
  _saveRecord(String name) {
    _triggerSnackBar('Saved', Icons.check);
    Cache().saveRecord((name.length > 0) ? name : _recordPath, _recordPath);
    this.timerState.currentState.reset();
    setState(() {
      _fadeController.reverse();
      _bouncyController.reverse();
      _recordPath = null;
    });
  }

  _deleteRecord() {
    _stopPlaying();
    _dialog.callInfoDialog(context, 'Are you sure ?', '', () {
      _triggerSnackBar('Removed', Icons.clear);
      File(_recordPath).delete();
      this.timerState.currentState.reset();
      setState(() {
        _fadeController.reverse();
        _bouncyController.reverse();
        _recordPath = null;
      });
    });
  }

  _triggerSnackBar(String text, IconData icon) {
    return Scaffold.of(context).showSnackBar(
      SnackBar(
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
