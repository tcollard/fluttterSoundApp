import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:myapp/common/dialog.dart';
import 'package:myapp/utils/cache.dart';
import 'package:flutter_share/flutter_share.dart';

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
    if (!mounted) {
      return;
    }
    setState(() {
      listSound = recordsJson;
      initBody();
    });
  }

  initBody() {
    if (listSound != null && listSound.length > 0) {
      return ReorderableListView(
        children: listSound.map((index) {
          return Container(
            color: (index['index'] % 2 == 0)
                ? Theme.of(context).primaryColor.withOpacity(0)
                : Theme.of(context).primaryColor.withOpacity(0.3),
            padding: EdgeInsets.only(top: 5, bottom: 5),
            key: ObjectKey(index),
            child: ListTile(
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
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
                          _triggerSnackBar('Modified', Icons.check);
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
                      _dialog.callInfoDialog(context, 'Delete Sound',
                          'Do you want to remove `${index["name"]}`', () {
                        _triggerSnackBar('Removed', Icons.clear);
                        setState(() {
                          deleteSound(index);
                        });
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.share,
                      size: 30,
                    ),
                    onPressed: () => share(index['path'], index['name']),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        onReorder: updateIndex,
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[Text('No sound for the momment')],
    );
  }

  void share(String filePath, String name) async {
    await FlutterShare.shareFile(
      title: 'Share Sound',
      text: name,
      filePath: filePath,
    );
  }

  updateIndex(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      var tmp = listSound.removeAt(oldIndex);
      listSound.insert(newIndex, tmp);
      Cache().saveRecordOrder(listSound);
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
