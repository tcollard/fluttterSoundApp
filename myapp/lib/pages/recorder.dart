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

class _RecorderPageState extends State<RecorderPage> {
  final AudioPlayer audioPlayer = AudioPlayer();
  Duration _duration;
  bool _isRecording = false;
  bool _isPlaying = false;
  String _recordPath;
  int recordingLength;
  Color color;
  Color splashColor;
  List<Widget> recordingAction = [];
  List<Widget> saveAction = [];
  AllDialog _dialog = AllDialog();

  final GlobalKey<TimerContentState> timerState =
      GlobalKey<TimerContentState>();
  final GlobalKey<ProgressBarState> progressBar = GlobalKey<ProgressBarState>();

  @override
  Widget build(BuildContext context) {
    Color _setColorBoxShadow() {
      return (Theme.of(context).brightness == Brightness.dark)
          ? Colors.white.withOpacity(0.05) // black background
          : Colors.white.withOpacity(1); // white background
    }

    recordingLength = recordingAction.length;
    color = (Theme.of(context).brightness == Brightness.light)
        ? Colors.black
        : Colors.white;
    splashColor = Theme.of(context).primaryColor;
    if (!this._isRecording && _recordPath == null) {
      recordingAction.clear();
      recordingAction.addAll(
        [
          Container(
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
            child: TimerContent(key: timerState),
          ),
          PrimaryCircularBtn3d(
            Icon(
              Icons.fiber_manual_record,
              color: Colors.redAccent,
              size: 80,
            ),
            200,
            Theme.of(context).scaffoldBackgroundColor,
            () {
              if (!_isRecording) _startRecord();
            },
          ),
        ],
      );
    } else if (this._isRecording) {
      recordingAction.replaceRange(
        recordingLength - 1,
        recordingLength,
        [
          PrimaryCircularBtn3d(
            SpinKitDoubleBounce(
              color: Colors.redAccent,
              size: 175,
            ),
            200,
            Theme.of(context).scaffoldBackgroundColor,
            () {
              if (_isRecording) _stopRecord();
            },
          ),
        ],
      );
    } else if (!this._isRecording && _recordPath != null && !this._isPlaying) {
      saveAction.clear();
      int index = recordingLength - ((recordingLength == 2) ? 1 : 2);
      recordingAction.replaceRange(
        index,
        index + 1,
        [
          PrimaryCircularBtn3d(
            Icon(
              Icons.play_arrow,
              color: color,
              size: 80,
            ),
            200,
            Theme.of(context).scaffoldBackgroundColor,
            () {
              _playRecord();
            },
          ),
        ],
      );
      if (recordingLength == 2) {
        recordingAction.add(
          Container(
            padding: const EdgeInsets.only(top: 50),
            child: ProgressBar(key: progressBar),
          ),
        );
      }
      saveAction.add(
        SecondaryCircularBtn3d(
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
                this.timerState.currentState.reset();
              },
            );
          },
        ),
      );
      saveAction.add(
        SecondaryCircularBtn3d(
          Icon(
            Icons.delete,
            color: color,
            size: 50,
          ),
          90,
          Theme.of(context).scaffoldBackgroundColor,
          () {
            _deleteRecord();
            this.timerState.currentState.reset();
          },
        ),
      );
    } else if (!this._isRecording && _recordPath != null && this._isPlaying) {
      recordingAction.replaceRange(recordingLength - 2, recordingLength - 1, [
        PrimaryCircularBtn3d(
          Icon(
            Icons.stop,
            color: color,
            size: 80,
          ),
          200,
          Theme.of(context).scaffoldBackgroundColor,
          () {
            _stopPlaying();
          },
        ),
      ]);
    }

    // return allActions;
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
    setState(() {
      saveAction.clear();
      _recordPath = null;
    });
  }

  _deleteRecord() {
    _stopPlaying();
    _dialog.callInfoDialog(context, 'Are you sure ?', '', () {
      _triggerSnackBar('Removed', Icons.clear);
      File(_recordPath).delete();
      setState(() {
        saveAction.clear();
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
