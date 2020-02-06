import 'dart:io';
import 'package:flutter/material.dart';
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
  Color whiteShadow;

  final GlobalKey<TimerContentState> timerState =
      GlobalKey<TimerContentState>();
  final GlobalKey<ProgressBarState> progressBar = GlobalKey<ProgressBarState>();

  _changeWhiteColorBoxShadow() {
    setState(() {
      whiteShadow = (Theme.of(context).brightness == Brightness.dark)
          ? Colors.white.withOpacity(0.1) // black background
          : Colors.white.withOpacity(1); // white background
    });
    return whiteShadow;
  }

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
            padding: EdgeInsets.only(top: 50),
            icon: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: Offset.fromDirection(.8, 20),
                        blurRadius: 20.0,
                        spreadRadius: 0.0),
                    BoxShadow(
                        color: _changeWhiteColorBoxShadow(),
                        offset: Offset.fromDirection(3.8, 15),
                        blurRadius: 20.0,
                        spreadRadius: 0.0),
                  ],
                  shape: BoxShape.circle,
                  color: Theme.of(context).scaffoldBackgroundColor),
              child: Icon(
                Icons.fiber_manual_record,
                color: Theme.of(context).backgroundColor,
                size: 80,
              ),
            ),
            color: color,
            splashColor: splashColor,
            iconSize: 200,
            onPressed: () {
              if (!_isRecording) _startRecord();
            }),
      ]);
    } else if (_isRecording) {
      recordingAction.replaceRange(recordingLength - 1, recordingLength, [
        IconButton(
            padding: EdgeInsets.only(top: 50),
            icon: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: Offset.fromDirection(.8, 20),
                      blurRadius: 20.0,
                      spreadRadius: 0.0),
                  BoxShadow(
                      color: _changeWhiteColorBoxShadow(),
                      offset: Offset.fromDirection(3.8, 15),
                      blurRadius: 20.0,
                      spreadRadius: 0.0),
                ],
                shape: BoxShape.circle,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: SpinKitDoubleBounce(
                color: Theme.of(context).backgroundColor,
                size: 175,
              ),
            ),
            color: color,
            splashColor: splashColor,
            iconSize: 200,
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
              if (!_isPlaying) {
                _playRecord();
              }
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
            _dialog.callMonoInputDialog(context, 'Insert name:', _recordPath,
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
      if (await AudioRecorder.hasPermissions) {
        this.timerState.currentState.start();
        await AudioRecorder.start();
        await AudioRecorder.isRecording;
        setState(() {
          _isRecording = true;
        });
      }
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
