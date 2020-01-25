import 'package:flutter/material.dart';
import 'package:myapp/common/customAppBar.dart';
import 'package:myapp/common/customDrawer.dart';

class RecorderPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(titleAppBar:'Recorder Page'),
      drawer: CustomDrawer(),
    );
  }
}