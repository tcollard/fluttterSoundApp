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
  List<Object> listSound = [];

  @override
  void initState() {
    // listSound = _initSoundList();
    _initSoundList();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(titleAppBar: 'Library'),
      drawer: CustomDrawer(),
      body: Container(
        child: Column(
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: listSound,
        ),
      ),
    );
  }

   _initSoundList() async {
    var recordsJson = await Cache().getRecord();

    List<Widget> truc = [];
    print('toto => ${recordsJson[0]["name"]}');
      
   }
}