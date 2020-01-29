import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myapp/common/customAppBar.dart';
import 'package:myapp/common/customDrawer.dart';
import 'package:myapp/utils/cache.dart';

class SoundLib extends StatefulWidget {
  @override
  _SoundLibState createState() => _SoundLibState();
}

class _SoundLibState extends State<SoundLib> {
  List<Widget> listSound = [];

  @override
  void initState() {
    super.initState();
    //   initSoundList().then((data) => this.listSound = data);
    //   print('HELLO $listSound');
    initSoundList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(titleAppBar: 'Library'),
      drawer: CustomDrawer(),
      body: ListView(
        children: this.listSound,
      ),
      // body: ReorderableListView(
      //   children: this.listSound,
      //   onReorder: (oldIndex, newIndex) {
      //     setState(() {
      //       updateIndex(oldIndex, newIndex);
      //     });
      //   },
      // ),
    );
  }

  initSoundList() async {
    var recordsJson = await Cache().getRecord();

    List<Widget> listTmp = [];
    print('toto => ${recordsJson[0]["name"]}');
    for (var i = 0; i < recordsJson.length; i++) {
      Card card = Card(
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              Text(recordsJson[i]["name"]),
              ButtonBar(
                children: <Widget>[
                  IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        print('Delete ${recordsJson[i]["name"]}');
                      }),
                  IconButton(
                      icon: Icon(Icons.mode_edit),
                      onPressed: () {
                        print('Edit ${recordsJson[i]["name"]}');
                      }),
                ],
              )
            ],
          ),
        ),
      );
      listTmp.add(card);
    }
    // for (var record in recordsJson) {
    //   ListTile card = ListTile(
    //     key: record["name"],
    //     title: Text(record["name"]),);
    //   listTmp.add(card);
    // }


    setState(() {
      this.listSound = listTmp;
    });
    // }
  }

  updateIndex(oldIndex, newIndex) {
    print('change index: ${listSound[oldIndex]}');
    ListTile tmp = listSound[oldIndex];
    listSound[oldIndex] = listSound[newIndex];
    listSound[newIndex] = tmp;
  }
}
