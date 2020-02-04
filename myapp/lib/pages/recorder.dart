import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myapp/common/dialog.dart';
import 'package:myapp/common/progressBar.dart';
import 'package:myapp/common/timer.dart';
import 'package:myapp/utils/cache.dart';
import 'package:audio_recorder/audio_recorder.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';

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

  final GlobalKey<TimerContentState> timerState =
      GlobalKey<TimerContentState>();
  final GlobalKey<ProgressBarState> progressBar = GlobalKey<ProgressBarState>();

  @override
  Widget build(BuildContext context) {
    recordingLength = recordingAction.length;
    color = (Theme.of(context).brightness == Brightness.light)
        ? Colors.black
        : Colors.white;
    splashColor = Theme.of(context).primaryColor;
    if (!_isRecording && _recordPath == null) {
      recordingAction.clear();
      recordingAction.addAll([
        TimerContent(key: timerState),
        IconButton(
            icon: Icon(Icons.fiber_manual_record),
            color: Colors.redAccent,
            splashColor: splashColor,
            iconSize: 60,
            onPressed: () {
              if (!_isRecording) _startRecord();
            }),
      ]);
    } else if (_isRecording) {
      recordingAction.replaceRange(recordingLength - 1, recordingLength, [
        IconButton(
            icon: Icon(Icons.stop),
            color: color,
            splashColor: splashColor,
            iconSize: 60,
            onPressed: () {
              if (_isRecording) _stopRecord();
            })
      ]);
    } else if (!_isRecording && _recordPath != null && !_isPlaying) {
      saveAction.clear();
      int index = recordingLength - ((recordingLength == 2) ? 1 : 2);
      recordingAction.replaceRange(
        index,
        index + 1,
        [
          IconButton(
            icon: Icon(Icons.play_arrow),
            color: color,
            splashColor: splashColor,
            iconSize: 60,
            onPressed: () {
              if (!_isPlaying) _playRecord();
            },
          ),
        ],
      );
      if (recordingLength == 2) {
        recordingAction.add(ProgressBar(key: progressBar));
      }
      saveAction.add(IconButton(
          icon: Icon(Icons.save),
          color: color,
          splashColor: splashColor,
          iconSize: 60,
          onPressed: () {
            InputDialog dial = InputDialog();
            dial.createAlertDialog(context, 'Inesrt name:', _recordPath,
                (data) {
              _saveRecord(data);
              this.timerState.currentState.reset();
            });
          }));
      saveAction.add(IconButton(
          icon: Icon(Icons.delete),
          color: color,
          splashColor: splashColor,
          iconSize: 60,
          onPressed: () {
            _deleteRecord();
            this.timerState.currentState.reset();
          }));
    } else if (!_isRecording && _recordPath != null && _isPlaying) {
      recordingAction.replaceRange(recordingLength - 2, recordingLength - 1, [
        IconButton(
          icon: Icon(Icons.stop),
          color: color,
          splashColor: splashColor,
          iconSize: 60,
          onPressed: () {
            if (_isPlaying) _stopPlaying();
          },
        )
      ]);
    }

    // return allActions;
    return ListView(
      children: [
        Container(
          padding: EdgeInsets.only(top: 120.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: recordingAction,
          ),
        ),
        Container(
          padding: EdgeInsets.only(bottom: 120.0),
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
    PermissionStatus microPpermission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.microphone);
    PermissionStatus storePpermission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);

    if (microPpermission != PermissionStatus.granted ||
        storePpermission != PermissionStatus.granted) {
      showDialog(
        context: context,
        builder: (_) => new AlertDialog(
          title: Text('ACCESS PERMISION'),
          content: Text('Please give me your permissions 🙏'),
          elevation: 24.0,
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () async {
                Navigator.pop(context);
                await PermissionHandler().openAppSettings();
              },
            ),
            FlatButton(
              child: Text('Never'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }
    try {
      if (await AudioRecorder.hasPermissions) {
        this.timerState.currentState.start();
        await AudioRecorder.start();
        await AudioRecorder.isRecording;
        setState(() {
          _isRecording = true;
        });
      } else {}
    } catch (e) {
      setState(() {
        _isRecording = false;
      });
    }
  }

  _stopRecord() async {
    try {
      this.timerState.currentState.stop();
      var recording = await AudioRecorder.stop();
      await AudioRecorder.isRecording;
      setState(() {
        _isRecording = false;
        _recordPath = recording.path;
        _duration = recording.duration;
      });
    } catch (e) {}
  }

  // PLAYING FUNCTION
  _playRecord() async {
    audioPlayer.onPlayerCompletion.listen((stop) {
      this.progressBar.currentState.updatePosition(_duration, _duration);
      setState(() {
        _isPlaying = false;
      });
    });
    audioPlayer.onAudioPositionChanged.listen((position) {
      this.progressBar.currentState.updatePosition(position, _duration);
    });
    setState(() {
      _isPlaying = true;
    });
    await audioPlayer.play(_recordPath, isLocal: true);
  }

  _stopPlaying() async {
    setState(() {
      _isPlaying = false;
    });
    await audioPlayer.stop();
  }

  // SAVE / DELETE RECORDING
  _saveRecord(String name) {
    Cache().saveRecord((name.length > 0) ? name : _recordPath, _recordPath);
    setState(() {
      saveAction.clear();
      _recordPath = null;
    });
  }

  _deleteRecord() {
    File(_recordPath).delete();
    setState(() {
      saveAction.clear();
      _recordPath = null;
    });
  }
}
