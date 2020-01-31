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
  List<Widget> displayList = [];
  final GlobalKey<TimerContentState> timerState = GlobalKey<TimerContentState>();
  

  @override
  Widget build(BuildContext context) {
    displayList = [];
    if (!_isRecording && _recordPath == null) {
      displayList = [];
      displayList.add(TimerContent(key: timerState));
      displayList.add(IconButton(
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
    } else if (_isRecording) {
      displayList = [];
      displayList.add(TimerContent(key: timerState));

      displayList.add(IconButton(
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
    } else if (!_isRecording && _recordPath != null) {
      displayList = [];
      displayList.add(IconButton(
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
      displayList.add(IconButton(
        icon: Icon(Icons.stop),
        color: (Theme.of(context).brightness == Brightness.light)
            ? Colors.yellow
            : Colors.green,
        splashColor: Theme.of(context).primaryColor,
        iconSize: 60,
        onPressed: () {
          if (_isPlaying) _stopPlaying();
        },
      ));
      displayList.add(IconButton(
          icon: Icon(Icons.save),
          color: (Theme.of(context).brightness == Brightness.light)
              ? Colors.black
              : Colors.white,
          splashColor: Theme.of(context).primaryColor,
          iconSize: 60,
          onPressed: () {
            _saveRecord();
          }));
      displayList.add(IconButton(
          icon: Icon(Icons.delete),
          color: (Theme.of(context).brightness == Brightness.light)
              ? Colors.black
              : Colors.white,
          splashColor: Theme.of(context).primaryColor,
          iconSize: 60,
          onPressed: () {
            _deleteRecord();
          }));
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: displayList,
      ),
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
    _isPlaying = true;
    await audioPlayer.play(_recordPath, isLocal: true);
  }

  _stopPlaying() async {
    _isPlaying = false;
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
