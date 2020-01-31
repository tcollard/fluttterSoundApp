import 'dart:io';
import 'package:flutter/material.dart';
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
  bool _isRecording = false;
  bool _isPlaying = false;
  String _recordPath;
  List<Widget> recordingAction = [];
  List<Widget> saveAction = [];
  Widget allActions;

  List<Widget> list = [];
  final GlobalKey<TimerContentState> timerState =
      GlobalKey<TimerContentState>();

  @override
  Widget build(BuildContext context) {
    if (!_isRecording && _recordPath == null) {
      recordingAction = [];
      recordingAction.add(TimerContent(key: timerState));
      recordingAction.add(IconButton(
          icon: Icon(Icons.fiber_manual_record),
          color: Colors.redAccent,
          splashColor: Theme.of(context).primaryColor,
          iconSize: 60,
          onPressed: () {
            if (!_isRecording) {
              _startRecord();
              this.timerState.currentState.start();
            }
          }));
      allActions = Center(
        child: Container(
          padding: EdgeInsets.only(top: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: recordingAction,
          ),
        ),
      );
    } else if (_isRecording) {
      setState(() {
        recordingAction.removeLast();
        recordingAction.add(IconButton(
            icon: Icon(Icons.stop),
            color: (Theme.of(context).brightness == Brightness.light)
                ? Colors.black
                : Colors.white,
            splashColor: Theme.of(context).primaryColor,
            iconSize: 60,
            onPressed: () {
              if (_isRecording) {
                _stopRecord();
                this.timerState.currentState.stop();
              }
            }));
        allActions = Center(
          child: Container(
            padding: EdgeInsets.only(top: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: recordingAction,
            ),
          ),
        );
      });
    } else if (!_isRecording && _recordPath != null && !_isPlaying) {
      setState(() {
        saveAction = [];
        recordingAction.removeLast();
        recordingAction.add(IconButton(
          icon: Icon(Icons.play_arrow),
          color: (Theme.of(context).brightness == Brightness.light)
              ? Colors.black
              : Colors.white,
          splashColor: Theme.of(context).primaryColor,
          iconSize: 60,
          onPressed: () {
            if (!_isPlaying) _playRecord();
          },
        ));
        saveAction.add(IconButton(
            icon: Icon(Icons.save),
            color: (Theme.of(context).brightness == Brightness.light)
                ? Colors.black
                : Colors.white,
            splashColor: Theme.of(context).primaryColor,
            iconSize: 60,
            onPressed: () {
              _saveRecord();
              this.timerState.currentState.reset();
            }));
        saveAction.add(IconButton(
            icon: Icon(Icons.delete),
            color: (Theme.of(context).brightness == Brightness.light)
                ? Colors.black
                : Colors.white,
            splashColor: Theme.of(context).primaryColor,
            iconSize: 60,
            onPressed: () {
              _deleteRecord();
              this.timerState.currentState.reset();
            }));
        allActions = Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: recordingAction,
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: saveAction,
              ),
            ),
          ],
        );
      });
    } else if (!_isRecording && _recordPath != null && _isPlaying) {
      setState(() {
        recordingAction.removeLast();
        recordingAction.add(IconButton(
          icon: Icon(Icons.stop),
          color: (Theme.of(context).brightness == Brightness.light)
              ? Colors.black
              : Colors.white,
          splashColor: Theme.of(context).primaryColor,
          iconSize: 60,
          onPressed: () {
            if (_isPlaying) _stopPlaying();
          },
        ));
        allActions = Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: recordingAction,
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: saveAction,
              ),
            ),
          ],
        );
      });
    }

    return allActions;
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
      var recording = await AudioRecorder.stop();
      await AudioRecorder.isRecording;
      setState(() {
        _isRecording = false;
        _recordPath = recording.path;
      });
    } catch (e) {}
  }

  // PLAYING FUNCTION
  _playRecord() async {
    audioPlayer.onPlayerCompletion.listen((stop) {
      setState(() {
        _isPlaying = false;
      });
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
  _saveRecord() {
    Cache().saveRecord(_recordPath, _recordPath);
    setState(() {
      _recordPath = null;
    });
  }

  _deleteRecord() {
    File(_recordPath).delete();
    setState(() {
      _recordPath = null;
    });
  }
}
