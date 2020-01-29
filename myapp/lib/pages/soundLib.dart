import 'package:flutter/material.dart';
import 'package:myapp/common/customAppBar.dart';
import 'package:myapp/common/customDrawer.dart';
import 'package:myapp/utils/cache.dart';

class SoundLib extends StatefulWidget {
  @override
  _SoundLibState createState() => _SoundLibState();
}

class _SoundLibState extends State<SoundLib> {
  List<dynamic> listSound = [];

  @override
  void initState() {
    super.initState();
    initSoundList();
    print('$listSound');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(titleAppBar: 'Library'),
      drawer: CustomDrawer(),
      body: ReorderableListView(
        children: listSound
            .map((index) => ListTile(
                  key: ObjectKey(index),
                  title: Text('${index['name']}'),
                ))
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
}
