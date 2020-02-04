import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:myapp/common/dialog.dart';
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
  Widget body;
  AllDialog _dialog = AllDialog();

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
    return initBody();
  }

  initSoundList() async {
    var recordsJson = await Cache().updateListRecords();
    setState(() {
      listSound = recordsJson;
      initBody();
    });
  }

  initBody() {
    if (listSound != null && listSound.length > 0) {
      return ReorderableListView(
        children: listSound
            .map(
              (index) => ExpansionTile(
                leading: IconButton(
                  icon: isPlaying && soundPlay == index['path']
                      ? Icon(
                          Icons.stop,
                          size: 30,
                        )
                      : Icon(
                          Icons.play_circle_outline,
                          size: 30,
                        ),
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
                key: ObjectKey(index),
                title: Text('${index['name']}'),
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.mode_edit,
                            size: 30,
                          ),
                          onPressed: () {
                            _dialog.callMonoInputDialog(
                                context, 'Change name', index['name'], (data) {
                              setState(() {
                                Cache().updateRecord('name', data, index);
                                index['name'] = data;
                              });
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_forever,
                            size: 30,
                          ),
                          onPressed: () {
                            _dialog.callInfoDialog(
                                context,
                                'Delete Sound',
                                'Do you want to remove `${index["name"]}`',
                                () {
                                      setState(() {
                                        deleteSound(index);
                                      });
                                    });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
            .toList(),
        onReorder: updateIndex,
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[Text('No sound for the momment')],
    );
  }

  updateIndex(int oldIndex, int newIndex) {
    setState(() {
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
    int i = listSound.indexWhere((elem) => elem == index);
    listSound.removeAt(i);
    Cache().removeRecord(index);
  }
}
