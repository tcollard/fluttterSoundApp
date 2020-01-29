import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:myapp/common/customAppBar.dart';
import 'package:myapp/common/customDrawer.dart';
import 'package:myapp/utils/cache.dart';

class SoundLib extends StatefulWidget {
  @override
  _SoundLibState createState() => _SoundLibState();
}

class _SoundLibState extends State<SoundLib> {
  final AudioPlayer audioPlayer = AudioPlayer();
  final inputNameController = TextEditingController();
  List<dynamic> listSound = [];
  bool isPlaying = false;
  String soundPlay;

  @override
  void initState() {
    super.initState();
    initSoundList();
  }

  @override
  void dispose() {
    inputNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(titleAppBar: 'Library'),
      drawer: CustomDrawer(),
      body: ReorderableListView(
        children: listSound
            .map((index) => ListTile(
                leading: Icon(Icons.music_note),
                key: ObjectKey(index),
                title: Text('${index['name']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: isPlaying && soundPlay == index['path']
                          ? Icon(Icons.stop)
                          : Icon(Icons.play_circle_outline),
                      onPressed: () {
                        setState(() {
                          if (isPlaying) {
                            stopSound();
                          } else {
                            playSound(index['path']);
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.mode_edit),
                      onPressed: () {
                        print('Edit');
                        showDialog(
                          context: context,
                          child: Dialog(
                            child: Column(
                              children: <Widget>[
                                Text('Change name:'),
                                TextField(
                                  controller: inputNameController,
                                  decoration:
                                      InputDecoration(hintText: index['name']),
                                ),
                                Row(
                                  children: <Widget>[
                                    FlatButton(
                                        child: Text('OK'),
                                        onPressed: () {
                                          print(
                                              'validation: ${inputNameController.text}');
                                          setState(() {
                                            Cache().updateRecord(
                                                'name',
                                                inputNameController.text,
                                                index);
                                            index['name'] =
                                                inputNameController.text;
                                          });

                                          Navigator.of(context).pop();
                                        }),
                                    FlatButton(
                                        child: Text('Cancel'),
                                        onPressed: () {
                                          print('Annulation');
                                          Navigator.of(context).pop();
                                          // Navigator.of(context).pop();
                                        }),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_forever),
                      onPressed: () {
                        setState(() {
                          deleteSound(index);
                        });
                      },
                    ),
                  ],
                )))
            .toList(),
        onReorder: updateIndex,
      ),
    );
  }

  initSoundList() async {
    var recordsJson = await Cache().getRecord();
    setState(() {
      listSound = recordsJson;
    });
  }

  updateIndex(int oldIndex, int newIndex) {
    setState(() {
      print('oldindex: $oldIndex');
      print('newindex: $newIndex');
      if (newIndex > oldIndex) newIndex -= 1;
      var tmp = listSound.removeAt(oldIndex);
      listSound.insert(newIndex, tmp);
    });
  }

  playSound(path) async {
    isPlaying = true;
    soundPlay = path;
    await audioPlayer.play(path, isLocal: true);
    audioPlayer.onPlayerCompletion.listen((event) {
      setState(() {
        isPlaying = false;
        soundPlay = null;
      });
    });
  }

  stopSound() async {
    isPlaying = false;
    await audioPlayer.stop();
  }

  deleteSound(index) {
    print('$listSound');
    int i = listSound.indexWhere((elem) => elem == index);
    listSound.removeAt(i);
    Cache().removeRecord(index);
  }
}
